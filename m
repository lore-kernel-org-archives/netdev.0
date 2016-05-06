From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [REGRESSION] asix: Lots of asix_rx_fixup() errors and slow
 transmissions
Date: Fri, 6 May 2016 17:27:32 +0200
Message-ID: <20160506152732.GA23647@lunn.ch>
References: <CALAqxLUj+-yUGTNviHu4+KE9=JTxjZyHBv4pdUob=xndAr8ZmA@mail.gmail.com>
 <57286E15.2080900@mentor.com>
 <CAFGCpxx0f7g7rXyZ-P0EF7QVX7Z0ziK+7VMPKK7pQteBowkw3Q@mail.gmail.com>
 <5728837D.60702@mentor.com>
 <CALAqxLXbMuK3Sj45vbf_r4GYQR=8bGUrhDz9-7+S2pbO_dJZ4A@mail.gmail.com>
 <572B0023.9060505@mentor.com>
 <CAFGCpxyeXkbQXW6Dm9ZpUXpVDWgaQziPnsC9GcZPqeg5jnbJUA@mail.gmail.com>
 <572CB188.7050203@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Guodong Xu <guodong.xu@linaro.org>,
	John Stultz <john.stultz@linaro.org>,
	lkml <linux-kernel@vger.kernel.org>,
	Mark Craske <Mark_Craske@mentor.com>,
	"David S. Miller" <davem@davemloft.net>,
	YongQin Liu <yongqin.liu@linaro.org>,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	Ivan Vecera <ivecera@redhat.com>,
	"David B. Robins" <linux@davidrobins.net>
To: Dean Jenkins <Dean_Jenkins@mentor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <572CB188.7050203@mentor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> In other words, the full-speed hub is restricting the USB to
> Ethernet Adaptor to a 12Mbps (half-duplex) bandwidth to support
> Ethernet 100Mbps (full-duplex) traffic. That is not going to work
> very well because Ethernet frames (perhaps partial Ethernet frames)
> need to be discarded within the USB link.

If that really is true, the design is broken. I would expect the
adaptor to reliably transfer whole frames over USB, and drop whole
frames from its receive queue when the USB is congested. TCP is also
going to see the USB bottleneck as just like any bottleneck in the
network and back off. So TCP streams should not cause major congestion
on the USB link. Going over a 12Mbps USB link should be no different
to hitting an old Ethernet hub which can only do 10/Half.

> Therefore please retest with a working high-speed USB hub or remove
> the full-speed USB hub from the test environment and directly
> connect the USB to Ethernet Adaptor to the root hub of the USB port.
> Then repeat the tests to see whether anything improved.
> 
> In other words, you need to eliminate the dmesg messages saying "not
> running at top speed; connect to a high speed hub".

I would also suggest testing with the Ethernet at 10/half. You should
be able to use Ethtool to set that up. Your USB and Ethernet bandwidth
become more equal. If you still see errors, it suggests a protocol
implementation error somewhere.

	 Andrew
