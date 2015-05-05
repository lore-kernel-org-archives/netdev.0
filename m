From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [RFC v1 07/11] net/mlx4: Cache irq_desc->affinity instead of
 irq_desc
Date: Tue, 5 May 2015 16:53:33 +0200 (CEST)
Message-ID: <alpine.DEB.2.11.1505051652280.4225@nanos>
References: <1430709339-29083-1-git-send-email-jiang.liu@linux.intel.com> <1430709339-29083-8-git-send-email-jiang.liu@linux.intel.com> <CAPcc5Ph4pk+4aL-PduvF67YU-A+vn2bfx6v3mr-tbY58zs7sZw@mail.gmail.com> <alpine.DEB.2.11.1505041708190.4225@nanos>
 <CAPcc5Pi7qNQKocTVmfZafVhi3MJwboY=XKYzNmqAnVqt0gU4vw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jiang Liu <jiang.liu@linux.intel.com>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Randy Dunlap <rdunlap@infradead.org>,
	Yinghai Lu <yinghai@kernel.org>,
	Borislav Petkov <bp@alien8.de>, Ido Shamay <idos@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eric Dumazet <edumazet@google.com>,
	Hadar Hen Zion <hadarh@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Joe Perches <joe@perches.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Matan Barak <matanb@mellanox.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Tony Luck <tony.luck@intel.com>, x86@kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	linux-pci@vger.kernel.org, linux-acpi@vger.kernel.org
To: Amir Vadai <amirv@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAPcc5Pi7qNQKocTVmfZafVhi3MJwboY=XKYzNmqAnVqt0gU4vw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 5 May 2015, Amir Vadai wrote:

> On Mon, May 4, 2015 at 6:10 PM, Thomas Gleixner <tglx@linutronix.de> wrote:
> > On Mon, 4 May 2015, Amir Vadai wrote:
> >
> >> On Mon, May 4, 2015 at 6:15 AM, Jiang Liu <jiang.liu@linux.intel.com> wrote:
> >> > The field 'affinity' in irq_desc won't change once the irq_desc data
> >> > structure is created. So cache irq_desc->affinity instead of irq_desc.
> >> > This also helps to hide struct irq_desc from device drivers.
> >>
> >> Hi Jiang,
> >>
> >> I might not understand the new changes irq core, but up until now
> >> affinity was changed when the user changed it through
> >> /proc/irq/<IRQ>/smp_affinity.
> >> This code is monitoring the affinity from the napi_poll context to
> >> detect affinity changes, and prevent napi from keep running on the
> >> wrong CPU.
> >> Therefore, the affinity can't be cached at the beginning. Please
> >> revert this caching.
> >
> > Sigh. All of this is completely wrong. Polling in the internals of
> > irq_desc is just crap.
> Hi,
> 
> >
> > irq_set_affinity_notifier() has been added for exactly this purpose.
> rmap is already registered on irq_set_affinity_notifier().
> Actually, I did post an extension to the affinity notifier, to use
> affinity chain which you rejected [1] (and BTW, convinced me that this
> is not the way to do it).
> Current code is according to your suggestion.
> 
> [1] - https://lkml.org/lkml/2014/5/26/222

No, it's not. I wrote:

 "So what's the point of adding notifier call chain complexity,
  ordering problems etc., if you can simply note the fact that the
  affinity changed in the rmap itself and check that in the RX path?"

I did not tell you to fiddle in irqdesc, really.

Thanks,

	tglx
