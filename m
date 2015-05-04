From: Jiang Liu <jiang.liu@linux.intel.com>
Subject: Re: [RFC v1 07/11] net/mlx4: Cache irq_desc->affinity instead of
 irq_desc
Date: Mon, 04 May 2015 22:00:38 +0800
Message-ID: <55477B86.70705@linux.intel.com>
References: <1430709339-29083-1-git-send-email-jiang.liu@linux.intel.com>	<1430709339-29083-8-git-send-email-jiang.liu@linux.intel.com> <CAPcc5Ph4pk+4aL-PduvF67YU-A+vn2bfx6v3mr-tbY58zs7sZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Thomas Gleixner <tglx@linutronix.de>,
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
	linux-pci@vger.kernel.org, linux-acpi@vger.kernel.org,
To: Amir Vadai <amirv@mellanox.com>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <CAPcc5Ph4pk+4aL-PduvF67YU-A+vn2bfx6v3mr-tbY58zs7sZw@mail.gmail.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2015/5/4 20:10, Amir Vadai wrote:
> On Mon, May 4, 2015 at 6:15 AM, Jiang Liu <jiang.liu@linux.intel.com> wrote:
>> The field 'affinity' in irq_desc won't change once the irq_desc data
>> structure is created. So cache irq_desc->affinity instead of irq_desc.
>> This also helps to hide struct irq_desc from device drivers.
> 
> Hi Jiang,
> 
> I might not understand the new changes irq core, but up until now
> affinity was changed when the user changed it through
> /proc/irq/<IRQ>/smp_affinity.
> This code is monitoring the affinity from the napi_poll context to
> detect affinity changes, and prevent napi from keep running on the
> wrong CPU.
> Therefore, the affinity can't be cached at the beginning. Please
> revert this caching.
Hi Amir,
	Thanks for review:) We want to hide irq_desc implementation
details from device drivers, so made these changes.
	Function irq_get_affinity_mask() returns 'struct cpumask *'
and we cache the returned pointer. On the other hand, user may change
IRQ affinity through /proc/irq/<IRQ>/smp_affinity, but that only
changes the bitmap pointed to by the cached pointer and won't change
the pointer itself. So it should always return the latest affinity
setting by calling cpumask_test_cpu(cpu_curr, cq->irq_affinity).
Or am I missing something here?
Thanks!
Gerry
> 
> Thanks,
> Amir
> 
