From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: DSA mv88e6xxx RX frame errors and TCP/IP RX failure
Date: Thu, 31 Aug 2017 19:41:41 +0200
Message-ID: <20170831174141.GP22289@lunn.ch>
References: <CAJ+vNU0VzgDkH-ksHgaA0cn3nbCOfcUs_BU90v6xw_QappssgA@mail.gmail.com>
 <20170830220631.GM22289@lunn.ch>
 <CAJ+vNU3Qto9iNdCUExb4NWaa3PA1UWe1kbY1b=sBLPgw_xiz7g@mail.gmail.com>
 <20170831014624.GA18554@lunn.ch>
 <CAJ+vNU0dq-ULUj3PbQH_biGviJURj2z5McCXx_vYxcB0k94WkA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Fugang Duan <fugang.duan@nxp.com>,
        Ilia Mirkin <imirkin@alum.mit.edu>
To: Tim Harvey <tharvey@gateworks.com>,
        David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAJ+vNU0dq-ULUj3PbQH_biGviJURj2z5McCXx_vYxcB0k94WkA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > I did fix an issue recently with that. See
> >
> > commit fbbeefdd21049fcf9437c809da3828b210577f36
> > Author: Andrew Lunn <andrew@lunn.ch>
> > Date:   Sun Jul 30 19:36:05 2017 +0200
> >
> >     net: fec: Allow reception of frames bigger than 1522 bytes
> >
> >     The FEC Receive Control Register has a 14 bit field indicating the
> >     longest frame that may be received. It is being set to 1522. Frames
> >     longer than this are discarded, but counted as being in error.
> >
> >     When using DSA, frames from the switch has an additional header,
> >     either 4 or 8 bytes if a Marvell switch is used. Thus a full MTU frame
> >     of 1522 bytes received by the switch on a port becomes 1530 bytes when
> >     passed to the host via the FEC interface.
> >
> >     Change the maximum receive size to 2048 - 64, where 64 is the maximum
> >     rx_alignment applied on the receive buffer for AVB capable FEC
> >     cores. Use this value also for the maximum receive buffer size. The
> >     driver is already allocating a receive SKB of 2048 bytes, so this
> >     change should not have any significant effects.
> >
> >     Tested on imx51, imx6, vf610.
> >
> >     Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> >     Signed-off-by: David S. Miller <davem@davemloft.net>
> >
> >
> > However, this is was of an all/nothing problem. All frames with the
> > full MTU were getting dropped, where as i think you are only seeing a
> > few dropped?
> >
> 
> Andrew,
> 
> Indeed this does resolve the issue. I see a burst of FIFO overruns
> initially when receiving an iperf bandwidth test but that would be
> caused by the IMX6 errata and should be mitigated via pause frames.
> After that short burst I see no other errors and iperf works fine.
> 
> Should we get this patch in the linux-stable tree for the 4.9 kernel?

Hi David

Please could you add

fbbeefdd2104 ("net: fec: Allow reception of frames bigger than 1522 bytes")

to stable.

Thanks
	Andrew
