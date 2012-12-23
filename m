From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [3.8-rc1] Networking problems after pulling-in net.git#master
Date: Sun, 23 Dec 2012 16:10:44 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1212231601330.1555@ja.ssi.bg>
References: <CA+icZUXJeWNceo_y-TSUVzXmjbrauWmCdkgW3EJtr_vpbcrk-A@mail.gmail.com> <20121223114213.GB8386@liondog.tnic> <CA+icZUXeddp5UZ10ZWTsWLnmegHGJ+VHnr4=oAm34hXgHD2FDg@mail.gmail.com> <CA+icZUU2OdNq5WKd7abNNe2eevxZBbMRS0eBGyU_rzjVBAgcOg@mail.gmail.com>
 <CA+icZUVxdp-Lcf4FLfY-80qvVsTQn-ajfh8vn2T=FC6-QbLv7w@mail.gmail.com> <CAM_iQpVdqYceHejqyQOn5wqj-xQFjn6E4u5ws4MuoOd=SiVtww@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: sedat.dilek@gmail.com, Borislav Petkov <bp@alien8.de>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:53097 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750947Ab2LWOJ5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Dec 2012 09:09:57 -0500
In-Reply-To: <CAM_iQpVdqYceHejqyQOn5wqj-xQFjn6E4u5ws4MuoOd=SiVtww@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Sun, 23 Dec 2012, Cong Wang wrote:

> On Sun, Dec 23, 2012 at 9:19 PM, Sedat Dilek <sedat.dilek@gmail.com> wrote:
> >
> > The culprit commit here seems to be...
> >
> > commit 9650388b5c56578fdccc79c57a8c82fb92b8e7f1
> > Author: Eric Dumazet <edumazet@google.com>
> > Date:   Fri Dec 21 07:32:10 2012 +0000
> >
> >     ipv4: arp: fix a lockdep splat in arp_solicit()
> 
> Can you try the following one-line fix?
> 
> Thanks.
> 
> ------------>
> 
> diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
> index 1169ed4..75e0d7c 100644
> --- a/net/ipv4/arp.c
> +++ b/net/ipv4/arp.c
> @@ -365,7 +365,7 @@ static void arp_solicit(struct neighbour *neigh,
> struct sk_buff *skb)
>                         pr_debug("trying to ucast probe in NUD_INVALID\n");
>                 neigh_ha_snapshot(dst_ha, neigh, dev);
>         } else {
> -               memset(dst_ha, 0, dev->addr_len);
> +               memcpy(dst_ha, dev->broadcast, MAX_ADDR_LEN);

	Use dev->addr_len instead of MAX_ADDR_LEN or
better provide NULL ptr to arp_send as before the
"ipv4: arp: fix a lockdep splat in arp_solicit" change,
for example by keeping dst_ha as pointer and using another
name for the temp array that is now dst_ha[MAX_ADDR_LEN].

>                 probes -= neigh->parms->app_probes;
>                 if (probes < 0) {
>  #ifdef CONFIG_ARPD

Regards

--
Julian Anastasov <ja@ssi.bg>
