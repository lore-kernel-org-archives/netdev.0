From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] netfilter: nf_nat: avoid double nat for loopback
Date: Tue, 7 Jun 2011 22:46:47 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1106072234140.1619@ja.ssi.bg>
References: <alpine.LFD.2.00.1106041640080.1437@ja.ssi.bg> <4DEDF167.1010202@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:46344 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753695Ab1FGToi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jun 2011 15:44:38 -0400
In-Reply-To: <4DEDF167.1010202@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tue, 7 Jun 2011, Patrick McHardy wrote:

> On 04.06.2011 16:02, Julian Anastasov wrote:
> > 
> > 	Avoid double NAT and seq adjustment for loopback
> > traffic because it causes silent repetition of TCP data. One
> > example is passive FTP with DNAT rule and difference in the
> > length of IP addresses.
> > 
> > 	This patch adds checks if packet is sent and
> > received via loopback device. As the same conntrack is used
> > both for outgoing and incoming direction, we restrict NAT,
> > seq adjustment and confirmation to happen only in
> > outgoing direction (OUTPUT and POSTROUTING).
> > 
> > Signed-off-by: Julian Anastasov <ja@ssi.bg>
> > ---
> > 
> > 	As the check is not so cheap, another alternative
> > is to add new skb flag, eg. "loopback", that can be set in 
> > drivers/net/loopback.c, loopback_xmit(). May be there is space
> > for it in flags2?
> 
> I don't think we should be adding code specifically needed for netfilter
> to the loopback driver if we can avoid it. I don't think we need to
> actually avoid calling nf_nat_packet twice, that shouldn't do any harm,
> just the sequence number adjustment. So we could add the loopback check

	Yes, may be calling nf_nat_packet is not fatal.

> to the IPS_SEQ_ADJUST_BIT case to at least avoid it in some cases.
> Would that work or am I missing something?

	Logically, the new check can be after
test_bit(IPS_SEQ_ADJUST_BIT, &ct->status). But I suspect
some modules adjust seqs in the helper->help call,
for example, sip_help_tcp if I'm correctly reading the
code.

Regards

--
Julian Anastasov <ja@ssi.bg>
