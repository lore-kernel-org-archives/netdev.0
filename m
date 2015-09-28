From: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Subject: RE: [PATCH V4 1/2] ACPI / EC: Fix broken 64bit big-endian users of
	'global_lock'
Date: Mon, 28 Sep 2015 08:58:17 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CBA3BF7@AcuExch.aculab.com>
References: <e28c4b4deaf766910c366ab87b64325da59c8ad6.1443198783.git.viresh.kumar@linaro.org>
	<2524822.pQu4UKMrlb@vostro.rjw.lan>
	<1443297128.2181.11.camel@HansenPartnership.com>
	<3461169.v5xKdGLGjP@vostro.rjw.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "moderated list:SOUND - SOC LAYER / DYNAMIC AUDIO
	POWER MANAGEM..." <alsa-devel-K7yf7f+aM1XWsZ/bQMPhNw@public.gmane.org>,
	Linaro Kernel Mailman List <linaro-kernel-cunTk1MwBs8s++Sfvej+rw@public.gmane.org>,
	"open list:TARGET SUBSYSTEM" <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Viresh Kumar <viresh.kumar-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	"open list:ULTRA-WIDEBAND \(UWB\) SUBSYSTEM:" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"open list:NETWORKING DRIVERS \(WIRELESS\)"
	<linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, QCA ath9k
	Development <ath9k-devel-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Intel Linux Wireless <ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"open list:AMD IOMMU \(AMD-VI\)" <iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	"open list:BLUETOOTH DRIVERS" <linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Memory Management List <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>,
	Greg Kroah-Hartman <gregkh@li
To: "'Rafael J. Wysocki'" <rjw-LthD3rsA81gm4RdzfppkhA@public.gmane.org>, James Bottomley
	<James.Bottomley-JuX6DAaQMKPCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <3461169.v5xKdGLGjP-sKB8Sp2ER+y1GS7QM15AGw@public.gmane.org>
Content-Language: en-US
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/iommu/>
List-Post: <mailto:iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Rafael J. Wysocki
> Sent: 27 September 2015 15:09
...
> > > Say you have three adjacent fields in a structure, x, y, z, each one byte long.
> > > Initially, all of them are equal to 0.
> > >
> > > CPU A writes 1 to x and CPU B writes 2 to y at the same time.
> > >
> > > What's the result?
> >
> > I think every CPU's  cache architecure guarantees adjacent store
> > integrity, even in the face of SMP, so it's x==1 and y==2.  If you're
> > thinking of old alpha SMP system where the lowest store width is 32 bits
> > and thus you have to do RMW to update a byte, this was usually fixed by
> > padding (assuming the structure is not packed).  However, it was such a
> > problem that even the later alpha chips had byte extensions.

Does linux still support those old Alphas?

The x86 cpus will also do 32bit wide rmw cycles for the 'bit' operations.

> OK, thanks!

You still have to ensure the compiler doesn't do wider rmw cycles.
I believe the recent versions of gcc won't do wider accesses for volatile data.

	David
