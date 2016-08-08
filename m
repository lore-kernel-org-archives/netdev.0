From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [PATCH net-next] cdc_ether: Improve ZTE MF823/831/910 handling
Date: Mon, 08 Aug 2016 15:57:00 +0200
Message-ID: <1470664620.3175.18.camel@suse.com>
References: <1468844691-8222-1-git-send-email-kristian.evensen@gmail.com>
	 <1468846886.2280.6.camel@suse.com>
	 <CAKfDRXiqDmJadXL4+v7saM431vPAp_8m8F0wvTkkYt-3tNjYyw@mail.gmail.com>
	 <1468849802.2280.11.camel@suse.com>
	 <CAKfDRXjaSz25_b8Na46DJEDvGUsZ-Xye+Rn2+o6Hy0EcuOopkA@mail.gmail.com>
	 <1468851242.2280.14.camel@suse.com> <87y4475t2f.fsf@miraculix.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Kristian Evensen <kristian.evensen@gmail.com>,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	Network Development <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87y4475t2f.fsf@miraculix.mork.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-08-08 at 14:44 +0200, Bjørn Mork wrote:
> Oliver Neukum <oneukum@suse.com> writes:

> > I don't see how it would be specific for a subsystem. If the patch
> > is correct, it belongs into the networking core.
> 
> The bug is in the firmware implementation of the "read unique vendor
> assigned mac address" functions, and should therefore be fixed there.

Well, if you define the semantics of the operation in that manner, it
certainly does. That however is not given. You could also define it
as returning the MAC the hardware listens to. The difference was just
unclear when the API was defined.

> It cannot be put into the networking core because "read unique vendor
> assigned mac address" is a hardware dependent function.  It's
> implemented in each ethernet driver based of whatever interface the
> firmware provides to that register.

Again, that depends on that particular semantics.

> IMHO, usbnet_get_ethernet_addr() would be the most appropriate place for
> cdc_ether and other CDC drivers. And generic_rndis_bind() is the correct
> place for rndis_host.
> 
> Putting this in usbnet_get_ethernet_addr() will also fix the XMM7160
> based devices having an FF:FF:FF:FF:FF:FF mac address (sic).  I'm pretty
> sure there are other examples too.  There is no end to the creative
> crazyness of firmware engineers...

It is clear that that would work. No question about that.

But why fix similar issues at two different places? And what about
PCI or other cards that show the same problem?

	Regards
		Oliver
