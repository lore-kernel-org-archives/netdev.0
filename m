From: John Heffner <jheffner@psc.edu>
Subject: Re: netif_rx packet dumping
Date: Thu, 3 Mar 2005 17:02:39 -0500 (EST)
Message-ID: <Pine.LNX.4.58.0503031657300.22311@tesla.psc.edu>
References: <20050303123811.4d934249@dxpl.pdx.osdl.net>
 <20050303125556.6850cfe5.davem@davemloft.net> <1109884688.1090.282.camel@jzny.localdomain>
 <20050303132143.7eef517c@dxpl.pdx.osdl.net> <1109885065.1098.285.camel@jzny.localdomain>
 <20050303133237.5d64578f.davem@davemloft.net> <20050303135416.0d6e7708@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>, hadi@cyberus.ca,
        rhee@eos.ncsu.edu, Yee-Ting.Li@nuim.ie, baruch@ev-en.org,
        netdev@oss.sgi.com
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050303135416.0d6e7708@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 3 Mar 2005, Stephen Hemminger wrote:

> On Thu, 3 Mar 2005 13:32:37 -0800
> "David S. Miller" <davem@davemloft.net> wrote:
>
> > On 03 Mar 2005 16:24:25 -0500
> > jamal <hadi@cyberus.ca> wrote:
> >
> > > Ok, this does sound more reasonable. Out of curiosity, are packets being
> > > dropped at the socket queue? Why is "dump till empty" behaviour screwing
> > > over TCP.
> >
> > Because it does the same thing tail-drop in routers do.
> > It makes everything back off a lot and go into slow start.
> > If we'd just drop 1 packet per flow or something like that
> > (so it could be fixed with a quick fast retransmit), TCP
> > would avoid regressing into slow start.
>
> Maybe a simple Random Exponential Drop (RED) would be more friendly.

That would probably not be appropriate.  This queue is only for absorbing
micro-scale bursts.  It should not hold any data in steady state like a
router queue can.  The receive window can handle the macro scale flow
control.

  -John
