From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: nf_nat: avoid double nat for loopback
Date: Tue, 07 Jun 2011 11:37:43 +0200
Message-ID: <4DEDF167.1010202@trash.net>
References: <alpine.LFD.2.00.1106041640080.1437@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1106041640080.1437@ja.ssi.bg>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04.06.2011 16:02, Julian Anastasov wrote:
> 
> 	Avoid double NAT and seq adjustment for loopback
> traffic because it causes silent repetition of TCP data. One
> example is passive FTP with DNAT rule and difference in the
> length of IP addresses.
> 
> 	This patch adds checks if packet is sent and
> received via loopback device. As the same conntrack is used
> both for outgoing and incoming direction, we restrict NAT,
> seq adjustment and confirmation to happen only in
> outgoing direction (OUTPUT and POSTROUTING).
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---
> 
> 	As the check is not so cheap, another alternative
> is to add new skb flag, eg. "loopback", that can be set in 
> drivers/net/loopback.c, loopback_xmit(). May be there is space
> for it in flags2?

I don't think we should be adding code specifically needed for netfilter
to the loopback driver if we can avoid it. I don't think we need to
actually avoid calling nf_nat_packet twice, that shouldn't do any harm,
just the sequence number adjustment. So we could add the loopback check
to the IPS_SEQ_ADJUST_BIT case to at least avoid it in some cases.
Would that work or am I missing something?
