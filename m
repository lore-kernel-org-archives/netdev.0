From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: netconsole breaks netpoll on bridge
Date: Tue, 17 Jun 2014 07:35:32 -0400
Message-ID: <20140617113532.GD8539@hmsreliant.think-freely.org>
References: <539EE86E.6030806@profihost.ag>
 <CAHA+R7OrT+x_jvDeqKgFc=ndebhB6qwecJBcT5y0ZAA+hBCJ3Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>,
	Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>,
	bridge@lists.linux-foundation.org,
	Linux Netdev List <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAHA+R7OrT+x_jvDeqKgFc=ndebhB6qwecJBcT5y0ZAA+hBCJ3Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 16, 2014 at 11:05:57AM -0700, Cong Wang wrote:
> On Mon, Jun 16, 2014 at 5:51 AM, Stefan Priebe - Profihost AG
> <s.priebe@profihost.ag> wrote:
> > Hi,
> >
> > i'm using a vanilla 3.10.43 kernel and netconsole on top of a bridge.
> >
> > netconsole is used with vmbr0 (bridge) which is on top of bond0.
> >
> > If i want to add another bridge to vmbr0 is fails as long as netconsole
> > is in use.
> >
> > # brctl addif vmbr0 fwpr2004p0
> > can't add fwpr2004p0 to bridge vmbr0: Unknown error 524
> >
> > Kernel output:
> > netpoll: (null): fwpr2004p0 doesn't support polling, aborting
> >
> > If i do rmmod netconsole - everything is working fine again.
> >
> 
> This is expected, you can't add an interface which doesn't support
> netpoll to a bridge which is running netpoll.
> 
> You should stop netpoll before adding it.
Or alternatively, update the driver for the fwpr2004p0 to support netpoll, and
you'll be able to add it with netpoll running

Neil

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
