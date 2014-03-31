From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: NFS does not work on linux-next 20140331
Date: Mon, 31 Mar 2014 18:54:29 +0200
Message-ID: <20140331165429.GB24150@order.stressinduktion.org>
References: <CAOMZO5DQ3dNB-R5rsd2X89XLbg_VYs7za8xQT2K-bWWmFS=YHA@mail.gmail.com> <1396283344.29410.55.camel@edumazet-glaptop2.roam.corp.google.com> <CAOMZO5Ac2s9bA8Af+ObDOR+5q0FJAnQ9RoGRO62tCpMvK-npbg@mail.gmail.com> <20140331164301.GA24150@order.stressinduktion.org> <CAOMZO5AQQoQK_2SM7QwfRYePKmf0Ci1=yMfH7reRwm_hWAVEyg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:42427 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752381AbaCaQya (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2014 12:54:30 -0400
Content-Disposition: inline
In-Reply-To: <CAOMZO5AQQoQK_2SM7QwfRYePKmf0Ci1=yMfH7reRwm_hWAVEyg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 31, 2014 at 01:50:58PM -0300, Fabio Estevam wrote:
> On Mon, Mar 31, 2014 at 1:43 PM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> 
> > Would you be able to quickly test this one?
> >
> > diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
> > index e1e4735..08b367c 100644
> > --- a/net/ipv6/mcast.c
> > +++ b/net/ipv6/mcast.c
> > @@ -1620,11 +1620,12 @@ static void mld_sendpack(struct sk_buff *skb)
> >                       dst_output);
> >  out:
> >         if (!err) {
> > -               ICMP6MSGOUT_INC_STATS_BH(net, idev, ICMPV6_MLD2_REPORT);
> > -               ICMP6_INC_STATS_BH(net, idev, ICMP6_MIB_OUTMSGS);
> > -               IP6_UPD_PO_STATS_BH(net, idev, IPSTATS_MIB_OUTMCAST, payload_len);
> > -       } else
> > -               IP6_INC_STATS_BH(net, idev, IPSTATS_MIB_OUTDISCARDS);
> > +               ICMP6MSGOUT_INC_STATS(net, idev, ICMPV6_MLD2_REPORT);
> > +               ICMP6_INC_STATS(net, idev, ICMP6_MIB_OUTMSGS);
> > +               IP6_UPD_PO_STATS(net, idev, IPSTATS_MIB_OUTMCAST, payload_len);
> > +       } else {
> > +               IP6_INC_STATS(net, idev, IPSTATS_MIB_OUTDISCARDS);
> > +       }
> 
> Thanks, Hannes. This makes NFS-mount to work fine again:
> 
> Tested-by: Fabio Estevam <fabio.estevam@freescale.com>

Thanks, Fabio!

Eric, do you mind if I take over, I'll audit the rest of the stack
regarding this change, too.
