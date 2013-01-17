From: Yan Burman <yanb@mellanox.com>
Subject: RE: [PATCH net] net/vxlan: Use the underlying device index when
 joining/leaving multicast groups
Date: Thu, 17 Jan 2013 15:19:43 +0000
Message-ID: <0EE9A1CDC8D6434DB00095CD7DB87346114E957C@MTLDAG02.mtl.com>
References: <1356010568-21644-1-git-send-email-yanb@mellanox.com>
 <20130114004652.GA11597@fliwatuet.svr02.mucip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Bernhard Schmidt <berni@birkenwald.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog106.obsmtp.com ([207.126.144.121]:58987 "HELO
	eu1sys200aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755844Ab3AQPTW convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jan 2013 10:19:22 -0500
In-Reply-To: <20130114004652.GA11597@fliwatuet.svr02.mucip.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> -----Original Message-----
> From: Bernhard Schmidt [mailto:berni@birkenwald.de]
> Sent: Monday, January 14, 2013 02:48
> To: Yan Burman
> Subject: Re: [PATCH net] net/vxlan: Use the underlying device index when
> joining/leaving multicast groups
> 
> In gmane.linux.network, Yan Burman wrote:
> 
> Hello,
> 
> thanks! That fixes my issue. Could you please submit this to -stable?
> 

>From my understanding David is the one submitting to -stable.
I can send it to -stable assuming it's ok with David.

Yan

> Thanks,
> Bernhard
> 
> > The socket calls from vxlan to join/leave multicast group aren't using
> > the index of the underlying device, as a result the stack uses the
> > first interface that is up. This results in vxlan being non functional
> > over a device which isn't the 1st to be up.
> > Fix this by providing the iflink field to the vxlan instance to the
> > multicast calls.
> >
> > Signed-off-by: Yan Burman <yanb@mellanox.com>
> > ---
> >  drivers/net/vxlan.c | 6 ++++--
> >  1 file changed, 4 insertions(+), 2 deletions(-)
> >
> > diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c index
> > 3b3fdf6..40f2cc1 100644
> > --- a/drivers/net/vxlan.c
> > +++ b/drivers/net/vxlan.c
> > @@ -505,7 +505,8 @@ static int vxlan_join_group(struct net_device *dev)
> >  	struct vxlan_net *vn = net_generic(dev_net(dev), vxlan_net_id);
> >  	struct sock *sk = vn->sock->sk;
> >  	struct ip_mreqn mreq = {
> > -		.imr_multiaddr.s_addr = vxlan->gaddr,
> > +		.imr_multiaddr.s_addr	= vxlan->gaddr,
> > +		.imr_ifindex		= vxlan->link,
> >  	};
> >  	int err;
> >
> > @@ -532,7 +533,8 @@ static int vxlan_leave_group(struct net_device
> *dev)
> >  	int err = 0;
> >  	struct sock *sk = vn->sock->sk;
> >  	struct ip_mreqn mreq = {
> > -		.imr_multiaddr.s_addr = vxlan->gaddr,
> > +		.imr_multiaddr.s_addr	= vxlan->gaddr,
> > +		.imr_ifindex		= vxlan->link,
> >  	};
> >
> >  	/* Only leave group when last vxlan is done. */
> > --
> > 1.7.11.3
> >
