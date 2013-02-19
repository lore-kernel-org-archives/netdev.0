From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: RE: [PATCH net-next v2 1/2] ip_gre: allow CSUM capable devices
 to handle packets
Date: Tue, 19 Feb 2013 19:20:06 +0000
Message-ID: <504C9EFCA2D0054393414C9CB605C37F1C019A30@SJEXCHMB06.corp.ad.broadcom.com>
References: <1361217053-16984-1-git-send-email-dmitry@broadcom.com>
 <CANvJab2uOKaGG6SrJCjvhe39oPqQbLBuc44j_nkShz_NW8G98w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: pravin <pravin.shelar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3517 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933020Ab3BSTUU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 14:20:20 -0500
In-Reply-To: <CANvJab2uOKaGG6SrJCjvhe39oPqQbLBuc44j_nkShz_NW8G98w@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> -----Original Message-----
> From: pravin [mailto:pravin.shelar@gmail.com]
> Sent: Tuesday, February 19, 2013 8:28 PM
> To: Dmitry Kravkov
> Cc: davem@davemloft.net; netdev@vger.kernel.org
> Subject: Re: [PATCH net-next v2 1/2] ip_gre: allow CSUM capable devices to
> handle packets
> 
> On Mon, Feb 18, 2013 at 11:50 AM, Dmitry Kravkov <dmitry@broadcom.com>
> wrote:
> > If device is not able to handle checksumming it will
> > be handled in dev_xmit
> >
> > Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> > ---
> > Changes from v1: fixed email address
> >
> >  net/ipv4/ip_gre.c |    7 ++-----
> >  1 files changed, 2 insertions(+), 5 deletions(-)
> >
> > diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
> > index a56f118..cdc31ac 100644
> > --- a/net/ipv4/ip_gre.c
> > +++ b/net/ipv4/ip_gre.c
> > @@ -745,12 +745,9 @@ static struct sk_buff *handle_offloads(struct sk_buff
> *skb)
> >                         goto error;
> >                 skb_shinfo(skb)->gso_type |= SKB_GSO_GRE;
> >                 return skb;
> > -       } else if (skb->ip_summed == CHECKSUM_PARTIAL) {
> > -               err = skb_checksum_help(skb);
> > -               if (unlikely(err))
> > -                       goto error;
> >         }
> > -       skb->ip_summed = CHECKSUM_NONE;
> > +       if (skb->ip_summed != CHECKSUM_PARTIAL)
> > +               skb->ip_summed = CHECKSUM_NONE;
> >
> >         return skb;
> >
> > --
> > 1.7.7.2
> >
> >
> 
> This patch breaks GRE tunnel with GRE_CSUM. since GRE_CSUM need
> complete IP packet to checksum entire GRE payload.

Testing for o_flags&GRE_CSUM does not look too hurt here, since it will be used in ipgre_tunnel_xmit() later on
This is the only problematic case, right?
 
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
