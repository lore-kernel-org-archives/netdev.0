From: P@draigBrady.com
Subject: Re: e1000 w/ NAPI + SMP = 99% CPU utilization
Date: Tue, 08 Jun 2004 13:34:52 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40C5B26C.7030305@draigBrady.com>
References: <BAY1-F101MkaFmV8ih90004a5a7@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Chris Carpinello <chriscarpinello@hotmail.com>
In-Reply-To: <BAY1-F101MkaFmV8ih90004a5a7@hotmail.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Chris Carpinello wrote:
> With a stock 2.6.5 kernel, I'm building the e1000 driver as a module
> w/ NAPI turned on for an SMP host (Dell PowerEdge 1650 with 4 1Gb
> Intel NICs).  ksoftirqd/0 is using 99% CPU utilization.  However, when
> I recompile the kernel with NAPI turned off, ksoftirqd/0 behaves
> normally.  Likewise, when I leave NAPI configured but turn off SMP
> support, ksoftirqd is fine.  The system in question has 2x Intel
> Corp. 82544EI (rev 02) and 2x Intel Corp. 82543GC (rev 02).
>=20
> I'm willing to test patches.  Please CC me on responses, as I'm not
> subscribed.  Thanks.

At what packet rate does it go to 100%?
Anyway it's not much to worry about as
it's in polling mode.

One thing which should help is to share
the work across your CPUs. `cat /proc/interrupts`
will show the interrupts for your nics.
Then you can bind the interrupt to a particular CPU like:

echo 1 > /proc/irq/$num/smp_affinity
echo 2 > /proc/irq/$num/smp_affinity
echo 4 > /proc/irq/$num/smp_affinity
echo 8 > /proc/irq/$num/smp_affinity

P=E1draig.
