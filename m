From: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Subject: Re: [PATCH V4 1/2] ACPI / EC: Fix broken 64bit big-endian users of
 'global_lock'
Date: Mon, 28 Sep 2015 07:26:46 -0700
Message-ID: <1443450406.2168.3.camel@HansenPartnership.com>
References: <e28c4b4deaf766910c366ab87b64325da59c8ad6.1443198783.git.viresh.kumar@linaro.org>
	 <2524822.pQu4UKMrlb@vostro.rjw.lan>
	 <1443297128.2181.11.camel@HansenPartnership.com>
	 <3461169.v5xKdGLGjP@vostro.rjw.lan>
	 <063D6719AE5E284EB5DD2968C1650D6D1CBA3BF7@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "'Rafael J. Wysocki'" <rjw-LthD3rsA81gm4RdzfppkhA@public.gmane.org>,
	Viresh Kumar <viresh.kumar-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Linaro Kernel Mailman List <linaro-kernel-cunTk1MwBs8s++Sfvej+rw@public.gmane.org>,
	QCA ath9k Development <ath9k-devel-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
	Intel Linux Wireless <ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	"linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"open list:BLUETOOTH DRIVERS" <linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"open list:AMD IOMMU (AMD-VI)" <iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"open list:NETWORKING DRIVERS (WIRELESS)"
	<linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"open list:TARGET SUBSYSTEM" <linux-scsi-u79uwXL29TY@public.gmane.org
To: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CBA3BF7-VkEWCZq2GCInGFn1LkZF6NBPR1lH4CV8@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-09-28 at 08:58 +0000, David Laight wrote:
> From: Rafael J. Wysocki
> > Sent: 27 September 2015 15:09
> ...
> > > > Say you have three adjacent fields in a structure, x, y, z, each one byte long.
> > > > Initially, all of them are equal to 0.
> > > >
> > > > CPU A writes 1 to x and CPU B writes 2 to y at the same time.
> > > >
> > > > What's the result?
> > >
> > > I think every CPU's  cache architecure guarantees adjacent store
> > > integrity, even in the face of SMP, so it's x==1 and y==2.  If you're
> > > thinking of old alpha SMP system where the lowest store width is 32 bits
> > > and thus you have to do RMW to update a byte, this was usually fixed by
> > > padding (assuming the structure is not packed).  However, it was such a
> > > problem that even the later alpha chips had byte extensions.
> 
> Does linux still support those old Alphas?
> 
> The x86 cpus will also do 32bit wide rmw cycles for the 'bit' operations.

That's different: it's an atomic RMW operation.  The problem with the
alpha was that the operation wasn't atomic (meaning that it can't be
interrupted and no intermediate output states are visible).

> > OK, thanks!
> 
> You still have to ensure the compiler doesn't do wider rmw cycles.
> I believe the recent versions of gcc won't do wider accesses for volatile data.

I don't understand this comment.  You seem to be implying gcc would do a
64 bit RMW for a 32 bit store ... that would be daft when a single
instruction exists to perform the operation on all architectures.

James


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
