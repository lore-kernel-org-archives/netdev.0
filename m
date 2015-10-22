From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [PATCH net] ppp: don't override sk->sk_state in pppoe_flush_dev()
Date: Thu, 22 Oct 2015 16:49:55 +0200
Message-ID: <20151022144955.GH2882@alphalink.fr>
References: <b7fbf103cd589741e3938550e7cf0f3684d8951c.1443605079.git.g.nault@alphalink.fr>
 <7045c1dad4647944f61c958511d45fcd@visp.net.lb>
 <20151002175426.GE2911@alphalink.fr>
 <356ca8b8094bb2460c0182c00e120378@visp.net.lb>
 <20151005120844.GF2911@alphalink.fr>
 <20151007121232.GF2882@alphalink.fr>
 <85baa6ab4293c475d0b4b26192694239@visp.net.lb>
 <1445472897.4157.38.camel@mattb-dl>
 <d5d182687f5319c9b4d82422b8c06789@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matt Bennett <Matt.Bennett@alliedtelesis.co.nz>, core@irc.lg.ua,
	netdev@vger.kernel.org, davem@davemloft.net, paulus@samba.org
To: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:36331 "EHLO
	mail-2-cbv2.admin.alphalink.fr" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S964806AbbJVOt7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 10:49:59 -0400
Content-Disposition: inline
In-Reply-To: <d5d182687f5319c9b4d82422b8c06789@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 22, 2015 at 03:53:33AM +0300, Denys Fedoryshchenko wrote:
> On 2015-10-22 03:14, Matt Bennett wrote:
> >On Tue, 2015-10-13 at 05:13 +0300, Denys Fedoryshchenko wrote:
> >>On 2015-10-07 15:12, Guillaume Nault wrote:
> >>> diff --git a/drivers/net/ppp/pppoe.c b/drivers/net/ppp/pppoe.c
> >>> index 2ed7506..5e0b432 100644
> >>> --- a/drivers/net/ppp/pppoe.c
> >>> +++ b/drivers/net/ppp/pppoe.c
> >>> @@ -589,7 +589,7 @@ static int pppoe_release(struct socket *sock)
> >>>
> >>>  	po = pppox_sk(sk);
> >>>
> >>> -	if (sk->sk_state & (PPPOX_CONNECTED | PPPOX_BOUND | PPPOX_ZOMBIE)) {
> >>> +	if (po->pppoe_dev) {
> >>>  		dev_put(po->pppoe_dev);
> >>>  		po->pppoe_dev = NULL;
> >>>  	}
> >>I just got OK to upgrade server yesterday, for now around 12 hours
> >>working fine. I need 1-2 more days, and maybe will upgrade few more
> >>servers to say for sure, if it is ok or not.
> >>Sorry for delay, just it is production servers and at current situation
> >>they cannot tolerate significant downtime.
> >>
> >Any update on whether this issue is fixed with the suggested patch?
> 
> As on server i am allowed to test - no crashed anymore, but i am unable to
> get permission yet to test
> on server where this crash was happening several times per day. But all i
> can say it is definitely better now.
> 
Good. It seems that more people are getting this problem, so I'm going
to submit the patch now.

I'm still interested in the result of your test on the second server
though.
