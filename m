From: Ingo Molnar <mingo@elte.hu>
Subject: Re: Poor UDP performance using 2.6.21-rc5-rt5
Date: Mon, 2 Apr 2007 08:30:18 +0200
Message-ID: <20070402063018.GA10209@elte.hu>
References: <461004CE.1030009@ieee.org> <461010F9.7040706@us.ibm.com> <20070402055509.GC3284@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dave Sperry <dave_sperry@ieee.org>, linux-rt-users@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Nivedita Singhvi <niv@us.ibm.com>
Return-path: <linux-rt-users-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070402055509.GC3284@elte.hu>
Sender: linux-rt-users-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Ingo Molnar <mingo@elte.hu> wrote:

> one thing to check would be whether both kernels use the same 
> clocksource, via:
> 
>  cat /sys/devices/system/clocksource/clocksource0/current_clocksource
> 
> but at first sight there's no clocksource related overhead in the 
> oprofile.

i've started a similar netperf test and clocksource overhead dominates 
the profile:

   5553 handle_fasteoi_irq                        26.1934
   5940 nv_start_xmit_optimized                    6.6892
   6014 ack_ioapic_quirk_irq                      44.5481
   7591 mask_IO_APIC_irq                         154.9184
   8155 __copy_from_user_ll                       37.4083
  13371 io_apic_base                             417.8438
  13565 get_next_timer_interrupt                  29.7478
  13966 __modify_IO_APIC_irq                     151.8043
  14213 do_irqd                                   22.7045
  17834 unmask_IO_APIC_irq                       424.6190
  20503 __schedule                                 6.4455
  48456 cpu_idle                                 180.8060
 170001 acpi_pm_read                             8947.4211
 517107 total                                      0.1566

acpi_pm_read() amounts to 32% overhead!

i'm not sure why the oprofile results show no clocksource overhead - the 
-rt kernel typically uses the pm-timer on Opterons.

to get more comparable results, boot the vanilla kernel with the 
"apicpmtimer" boot option, and/or do this after bootup:

 echo acpi_pm > /sys/devices/system/clocksource/clocksource0/current_clocksource

	Ingo
