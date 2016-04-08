From: Weongyo Jeong <weongyo.linux@gmail.com>
Subject: Re: [PATCH v2] packet: uses kfree_skb() for drops or errors.
Date: Fri, 8 Apr 2016 09:27:25 -0700
Message-ID: <20160408162723.GA23549@jwg>
References: <1459977298-16670-1-git-send-email-weongyo.linux@gmail.com>
 <CAF=yD-K9f_kPB5itNW_xdg8LOuSGhNsmb0B1Ur8fR12LN=_Syw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Network Development <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:35677 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751981AbcDHQ11 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 12:27:27 -0400
Received: by mail-pa0-f68.google.com with SMTP id zy2so9407208pac.2
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2016 09:27:27 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAF=yD-K9f_kPB5itNW_xdg8LOuSGhNsmb0B1Ur8fR12LN=_Syw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 07, 2016 at 12:06:12PM -0400, Willem de Bruijn wrote:
> On Wed, Apr 6, 2016 at 5:14 PM, Weongyo Jeong <weongyo.linux@gmail.com> wrote:
> > consume_skb() isn't for drop or error cases
> 
> for drop or error -> for error
> 
> > that  kfree_skb() is more proper
> > one.  At this patch, it fixed tpacket_rcv() and packet_rcv() to be
> > consistent for error or non-error cases letting perf trace its event
> > properly.
> >
> > Signed-off-by: Weongyo Jeong <weongyo.linux@gmail.com>
> 
> Don't forget to add the target to your subject line: PATCH net-next v3.
> 
> > ---
> >  net/packet/af_packet.c | 16 ++++++++++++----
> >  1 file changed, 12 insertions(+), 4 deletions(-)
> >
> > diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> > index 1ecfa71..cd100cf 100644
> > --- a/net/packet/af_packet.c
> > +++ b/net/packet/af_packet.c
> > @@ -2040,7 +2040,7 @@ static int packet_rcv(struct sk_buff *skb, struct net_device *dev,
> >         struct sockaddr_ll *sll;
> >         struct packet_sock *po;
> >         u8 *skb_head = skb->data;
> > -       int skb_len = skb->len;
> > +       int err = 0, skb_len = skb->len;
> 
> bool
> 
> Otherwise looks good.

Thank you for review Willem. I just had submitted v3 version.

Regards,
Weongyo Jeong
