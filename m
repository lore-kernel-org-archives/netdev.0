From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] udp: prevent skbs lingering in tunnel socket queues
Date: Fri, 20 May 2016 00:50:34 +0200
Message-ID: <1463698234.591755.613149449.668265D8@webmail.messagingengine.com>
References: <1463666313-12743-1-git-send-email-hannes@stressinduktion.org>
 <CAM_iQpXOxcT+P2mxF9okdeD2d-=mXXxba6c-AQk-hgv7qian2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:56660 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755255AbcESWug (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2016 18:50:36 -0400
Received: from compute7.internal (compute7.nyi.internal [10.202.2.47])
	by mailout.nyi.internal (Postfix) with ESMTP id 3378520AA9
	for <netdev@vger.kernel.org>; Thu, 19 May 2016 18:50:35 -0400 (EDT)
In-Reply-To: <CAM_iQpXOxcT+P2mxF9okdeD2d-=mXXxba6c-AQk-hgv7qian2A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Cong,

On Fri, May 20, 2016, at 00:33, Cong Wang wrote:
> On Thu, May 19, 2016 at 6:58 AM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> > diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> > index 2e3ebfe5549ef5..d56c0559b477cb 100644
> > --- a/net/ipv4/udp.c
> > +++ b/net/ipv4/udp.c
> > @@ -1565,7 +1565,7 @@ int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
> >
> >                 /* if we're overly short, let UDP handle it */
> >                 encap_rcv = ACCESS_ONCE(up->encap_rcv);
> > -               if (skb->len > sizeof(struct udphdr) && encap_rcv) {
> > +               if (encap_rcv) {
> 
> 
> I don't think you can just remove it here, l2tp_udp_recv_core() still
> relies on it:
> 
>         /* UDP has verifed checksum */
> 
>         /* UDP always verifies the packet length. */
>         __skb_pull(skb, sizeof(struct udphdr));

I think this is fine, we check on every entrance to udp that we may pull
(pskb_may_pull) an udphdr but we really never pull the header. At this
point we are guaranteed to have skb->len of at least sizeof(struct
udphdr).

Bye,
Hannes
