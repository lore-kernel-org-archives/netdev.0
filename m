From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: 3.2-rc2+: Reported regressions from 3.0 and 3.1
Date: Thu, 1 Dec 2011 09:35:48 -0500
Message-ID: <20111201143548.GA28114@phenom.dumpdata.com>
References: <lx6sezwGldO.A.IhF.UBpWOB@chimera> <201111212249.31196.rjw@sisk.pl>
	<20111122135412.GA29905@phenom.dumpdata.com>
	<20111129180414.GA11459@phenom.dumpdata.com>
	<20111129183428.GE8200@aftab>
	<20111130175936.GA15168@phenom.dumpdata.com>
	<20111201113919.GC31552@aftab>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Linux SCSI List <linux-scsi@vger.kernel.org>,
	Florian Mickler <florian@mickler.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>, x86@kernel.org,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	DRI <dri-devel@lists.freedesktop.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>, mingo@redhat.com,
	hpa@zytor.com, tglx@linutronix.de,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Maciej Rutecki <maciej.rutecki@gmail.com>
To: Borislav Petkov <bp@amd64.org>
Return-path: <linux-pm-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20111201113919.GC31552@aftab>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/linux-pm/>
List-Post: <mailto:linux-pm@lists.linux-foundation.org>
List-Help: <mailto:linux-pm-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=subscribe>
Sender: linux-pm-bounces@lists.linux-foundation.org
Errors-To: linux-pm-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

> >From what I can see, you get the following callchain:
> 
> start_kernel
> |-> setup_arch
>     |-> x86_init.oem.arch_setup = xen_arch_setup
>     ....
>     |-> check_bugs
>         |-> identify_boot_cpu
> 	    |-> identify_cpu
> 	        |-> select_idle_routine
> 
> 
> so xen_arch_setup will set pm_idle and select_idle_routine will honour
> it. I'm being told this is run either in the dom0 or the paravirt guest
> and if so, I don't see any issue with this for baremetal. So you can
> have my ACK provided this is tested on baremetal too.

Tested on baremetal and there were no abnormalities. Thanks!
