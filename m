From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [v9 PATCH 2/3] NETFILTER module xt_hmark, new target for HASH based fwmark
Date: Mon, 5 Mar 2012 12:28:18 +0100
Message-ID: <201203051228.20049.hans.schillstrom@ericsson.com>
References: <1329387672-23683-1-git-send-email-hans.schillstrom@ericsson.com> <201203051109.48817.hans.schillstrom@ericsson.com> <alpine.LNX.2.01.1203051140470.19304@frira.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"hans@schillstrom.com" <hans@schillstrom.com>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.01.1203051140470.19304@frira.zrqbmnf.qr>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 05 March 2012 11:48:16 Jan Engelhardt wrote:
> 
> On Monday 2012-03-05 11:09, Hans Schillstrom wrote:
> >> > diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
> >> > index 40f4c3d..21bc5e8 100644
> >> > --- a/net/netfilter/Makefile
> >> > +++ b/net/netfilter/Makefile
> >> > @@ -57,6 +57,7 @@ obj-$(CONFIG_NETFILTER_XT_TARGET_CONNSECMARK) += xt_CONNSECMARK.o
> >> >  obj-$(CONFIG_NETFILTER_XT_TARGET_CT) += xt_CT.o
> >> >  obj-$(CONFIG_NETFILTER_XT_TARGET_DSCP) += xt_DSCP.o
> >> >  obj-$(CONFIG_NETFILTER_XT_TARGET_HL) += xt_HL.o
> >> > +obj-$(CONFIG_NETFILTER_XT_TARGET_HMARK) += xt_hmark.o
> >> 
> >> Netfilter's naming policy requires that targets are in upper case.
> >
> >I asked netfilter team about that, and got the answer
> >that it should be lower case for new modules.
> >Have that been changed ?
> 
> The name of the file is pretty much irrelevant (because loading
> solely depends on MODULE_ALIAS), so I share that only lowercase
> should be used for new things. It's not that the linux kernel would
> currently be storable on a case-insensitive filesystem, but that does
> not mean we can't latently work towards it.

OK

> >static int get_inner_hdr(struct sk_buff *skb, int *nhoff)
> >{
> >	const struct icmphdr *icmph;
> >	struct icmphdr _ih;
> >	int iphz = ((struct iphdr *)skb_network_header(skb))->ihl * 4;
> 
> unsigned int iphz = skb_hdrlen(skb);
> 
> >> > +static unsigned int
> >> > +hmark_v6(struct sk_buff *skb, const struct xt_action_param *par)
> >> > +{
> >> > +     struct xt_hmark_info *info = (struct xt_hmark_info *)par->targinfo;
> 
> Pointless cast.

Yes, better to add a const in front of struct hmark

> 
> >> > +     union hmark_ports uports = { .v32 = 0 };
> >> 
> >> I think that this can be: union hmark_ports uports = {};
> 
> NB: Strictly speaking, {} is a GNU extension to saying {0} (or {{0}} or
> {{{{{0}}}}} etc, which ever applies).

Thanks, but I still don't think "= {}"; is obvious what it does :-) 
It kan be nice if you have a lot to clear;

> 
> >> > +static unsigned int
> >> > +hmark_v4(struct sk_buff *skb, const struct xt_action_param *par)
> >> > +{
> >> > +     struct xt_hmark_info *info = (struct xt_hmark_info *)par->targinfo;
> 
> Same pointless cast.
> 

-- 
Thanks
Hans 
