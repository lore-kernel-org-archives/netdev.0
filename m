From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2.39 6/7] datapath: Break out deacceleration portion of
 vlan_push
Date: Thu, 19 Sep 2013 09:56:09 -0500
Message-ID: <20130919145606.GB24919@verge.net.au>
References: <1378711207-29890-1-git-send-email-horms@verge.net.au>
 <1378711207-29890-7-git-send-email-horms@verge.net.au>
 <CAEP_g=_ZQ6hNpxoHm6t3N=PxA+3WTrvNegL514j0R3GDM5C92A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>, Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Pravin B Shelar <pshelar@nicira.com>,
	Joe Stringer <joe@wand.net.nz>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:45055 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751751Ab3ISO7g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Sep 2013 10:59:36 -0400
Content-Disposition: inline
In-Reply-To: <CAEP_g=_ZQ6hNpxoHm6t3N=PxA+3WTrvNegL514j0R3GDM5C92A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 13, 2013 at 03:07:12PM -0700, Jesse Gross wrote:
> On Mon, Sep 9, 2013 at 12:20 AM, Simon Horman <horms@verge.net.au> wrote:
> > diff --git a/datapath/actions.c b/datapath/actions.c
> > index 30ea1d2..6741d81 100644
> > --- a/datapath/actions.c
> > +++ b/datapath/actions.c
> > @@ -105,22 +105,29 @@ static int pop_vlan(struct sk_buff *skb)
> >         return 0;
> >  }
> >
> > -static int push_vlan(struct sk_buff *skb, const struct ovs_action_push_vlan *vlan)
> > +/* push down current VLAN tag */
> > +static struct sk_buff *put_vlan(struct sk_buff *skb)
> 
> This never changes the skb, right? Can we simplify things and just
> return an error code?

Yes. I'm not sure what I was thinking when I chose not to do that
but I will change things around as you suggest.
