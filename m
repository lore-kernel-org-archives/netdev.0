From: Dave Young <hidave.darkstar@gmail.com>
Subject: Re: [Ksummit-2010-discuss] [v2] Remaining BKL users, what to do
Date: Wed, 20 Oct 2010 12:43:21 +0800
Message-ID: <AANLkTimRFxKT5p1K=Rd1MxXZymonx_t6rHKBhn=8CsW=@mail.gmail.com>
References: <201009161632.59210.arnd@arndb.de>
	<201010192140.47433.oliver@neukum.org>
	<20101019202912.GA30133@kroah.com>
	<201010192244.41913.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg KH <greg@kroah.com>, Oliver Neukum <oliver@neukum.org>,
	Valdis.Kletnieks@vt.edu, Dave Airlie <airlied@gmail.com>,
	codalist@telemann.coda.cs.cmu.edu,
	ksummit-2010-discuss@lists.linux-foundation.org,
	autofs@linux.kernel.org, Jan Harkes <jaharkes@cs.cmu.edu>,
	Samuel Ortiz <samuel@sortiz.org>, Jan Kara <jack@suse.cz>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	netdev@vger.kernel.org, Anders Larsen <al@alarsen.net>,
	linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org,
	Bryan Schumaker <bjschuma@netapp.com>,
	Christoph Hellwig <hch@infradead.org>,
	Petr Vandrovec <vandrove@vc.cvut.cz>,
	Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>,
	linux-fsdevel@vger.kernel.org,
	Evgeniy Dushistov <dushistov@mail.ru>,
	Ingo Molnar <mingo@elte.hu>,
	Andrew Hendry <andrew.hendry@gmail.com>,
	linux-media@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201010192244.41913.arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 20, 2010 at 4:44 AM, Arnd Bergmann <arnd@arndb.de> wrote:
> On Tuesday 19 October 2010 22:29:12 Greg KH wrote:
>> On Tue, Oct 19, 2010 at 09:40:47PM +0200, Oliver Neukum wrote:
>> > Am Dienstag, 19. Oktober 2010, 21:37:35 schrieb Greg KH:
>> > > > So no need to clean it up for multiprocessor support.
>> > > >
>> > > > http://download.intel.com/design/chipsets/datashts/29067602.pd=
f
>> > > > http://www.intel.com/design/chipsets/specupdt/29069403.pdf
>> > >
>> > > Great, we can just drop all calls to lock_kernel() and the like =
in the
>> > > driver and be done with it, right?
>> >
>> > No,
>> >
>> > you still need to switch off preemption.
>>
>> Hm, how would you do that from within a driver?
>
> I think this would do:
> ---
> drm/i810: remove SMP support and BKL
>
> The i810 and i815 chipsets supported by the i810 drm driver were not
> officially designed for SMP operation, so the big kernel lock is
> only required for kernel preemption. This disables the driver if
> preemption is enabled and removes all calls to lock_kernel in it.
>
> If you own an Acorp 6A815EPD mainboard with a i815 chipset and
> two Pentium-III sockets, and want to run recent kernels on it,
> tell me about it.
>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>
> diff --git a/drivers/gpu/drm/Kconfig b/drivers/gpu/drm/Kconfig
> index b755301..e071bc8 100644
> --- a/drivers/gpu/drm/Kconfig
> +++ b/drivers/gpu/drm/Kconfig
> @@ -73,8 +73,8 @@ source "drivers/gpu/drm/radeon/Kconfig"
>
> =C2=A0config DRM_I810
> =C2=A0 =C2=A0 =C2=A0 =C2=A0tristate "Intel I810"
> - =C2=A0 =C2=A0 =C2=A0 # BKL usage in order to avoid AB-BA deadlocks,=
 may become BROKEN_ON_SMP
> - =C2=A0 =C2=A0 =C2=A0 depends on DRM && AGP && AGP_INTEL && BKL
> + =C2=A0 =C2=A0 =C2=A0 # PREEMPT requires BKL support here, which was=
 removed
> + =C2=A0 =C2=A0 =C2=A0 depends on DRM && AGP && AGP_INTEL && !PREEMPT

be curious, why can't just fix the lock_kernel logic of i810? Fixing
is too hard?

=46ind a i810 hardware should be possible, even if the hardware does no=
t
support SMP, can't we test the fix with preemption?

--=20
Regards
dave
