From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] netfilter: nf_nat: avoid double nat for loopback
Date: Wed, 8 Jun 2011 09:26:04 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1106080913150.1457@ja.ssi.bg>
References: <alpine.LFD.2.00.1106041640080.1437@ja.ssi.bg> <4DEDF167.1010202@trash.net> <alpine.LFD.2.00.1106072234140.1619@ja.ssi.bg> <4DEEAD6F.8050505@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4DEEAD6F.8050505@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


	Hello,

On Wed, 8 Jun 2011, Patrick McHardy wrote:

> >> to the IPS_SEQ_ADJUST_BIT case to at least avoid it in some cases.
> >> Would that work or am I missing something?
> > 
> > 	Logically, the new check can be after
> > test_bit(IPS_SEQ_ADJUST_BIT, &ct->status). But I suspect
> > some modules adjust seqs in the helper->help call,
> > for example, sip_help_tcp if I'm correctly reading the
> > code.
> 
> Yes, you're right. But it's the only one since it's the only helper
> doing possibly many modifications on a single TCP packet, which can't
> be handled by the generic code properly. So if you're worried about
> performance costs, I'd have no problems adding this check to the SIP
> helper.

	OK, I'm posting new version just for seq adjustment.
I'm not fixing sip_help_tcp because I'm not sure what is
the right fix, we must be sure that calling sip_help_tcp
twice is not a problem.

Regards

--
Julian Anastasov <ja@ssi.bg>
