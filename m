From: Steve Calfee <stevecalfee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net 1/4] pegasus: Use heap buffers for all register access
Date: Tue, 7 Feb 2017 10:32:16 -0800
Message-ID: <CAJJ6jxt-47saW=B260j0v_Gdt-dwb4YepRZTWQ-nYfLBGQUT=w@mail.gmail.com>
References: <20170204165451.GU3442@decadent.org.uk> <20170204165603.GV3442@decadent.org.uk>
 <20170205003038.GB21184@kroah.com> <20170206081444.smcgjkmdepxoosb6@p310>
 <20170206082822.GA23451@kroah.com> <20170206125108.d5vdur5rlvrkpr5j@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, USB list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        =?UTF-8?Q?Lisandro_Dami=C3=A1n_Nicanor_P=C3=A9rez_Meyer?=
        <lisandro-8fiUuRrzOP0dnm+yROfE0A@public.gmane.org>
To: Petko Manolov <petkan-nPnTwAqkgEqakBO8gow8eQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170206125108.d5vdur5rlvrkpr5j@localhost>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 6, 2017 at 4:51 AM, Petko Manolov <petkan-nPnTwAqkgEqakBO8gow8eQ@public.gmane.org> wrote:
> On 17-02-06 09:28:22, Greg KH wrote:
>> On Mon, Feb 06, 2017 at 10:14:44AM +0200, Petko Manolov wrote:
>> > On 17-02-05 01:30:39, Greg KH wrote:
>> > > On Sat, Feb 04, 2017 at 04:56:03PM +0000, Ben Hutchings wrote:
>> > > > Allocating USB buffers on the stack is not portable, and no longer works
>> > > > on x86_64 (with VMAP_STACK enabled as per default).
>> > >
>> > > It's never worked on other platforms, so these should go to the stable
>> > > releases please.
>> >
>> > As far as i know both drivers works fine on other platforms, though I only
>> > tested it on arm and mipsel. ;)
>>
>> It all depends on the arm and mips platforms, the ones that can not DMA from
>> stack memory are the ones that would always fail here (since the 2.2 kernel
>> days).
>
> Seems like most modern SOCs have decent DMA controllers.
>

The real problem is not DMA exactly, it is cache coherency.

X86 has a coherent cache and all the cpu cores watch DMA transfers and
keep the cpu caches up to date.

Most ARMs and MIPS processors have incoherent cache, so DMA can change
memory without the CPU cache updates. CPU cache view of what is in
memory can be different from what was DMAed in, this makes failures
very hard to detect, reproduce and racy.

So all DMA buffers should always be separate allocations from the
stack AND not be embedded in structs. Memory allocations are always at
least cache line aligned, so coherency is not a problem.

Regards, Steve
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
