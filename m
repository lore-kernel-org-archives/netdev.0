From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 11545] New: e1000e: Sometimes
 causes resume from suspend to RAM to fail
Date: Fri, 12 Sep 2008 09:05:20 -0700
Message-ID: <20080912090520.ac012e55.akpm@linux-foundation.org>
References: <bug-11545-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, elendil@planet.nl,
	bugme-daemon@bugzilla.kernel.org
To: e1000-devel@lists.sourceforge.net
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <bug-11545-10286@http.bugzilla.kernel.org/>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Fri, 12 Sep 2008 02:42:03 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=11545
> 
>            Summary: e1000e: Sometimes causes resume from suspend to RAM to
>                     fail
>            Product: Drivers
>            Version: 2.5
>      KernelVersion: 2.6.27-rc6
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: jgarzik@pobox.com
>         ReportedBy: elendil@planet.nl
>                 CC: rjw@sisk.pl
> 
> 
> Latest working kernel version: Unknown
> Earliest failing kernel version: Unknown; first seen with 2.6.27-rc4
> Distribution: Debian
> Hardware Environment: HP Compaq 2510p laptop
> Software Environment: Debian unstable
> 
> Problem Description:
> Most of the time the laptop resumes perfectly from suspend, but sometimes
> (about 1 in 5-10 times) it fails to resume fairly early (with the display still
> off). Only solution at that point is a hard power off.
> 
> I've used pm_trace to try to find out the cause of the failure. That gave:
>   Magic number: 0:983:221
>   hash matches drivers/base/power/main.c:350
> e1000e 0000:00:19.0: hash matches
> rtc_cmos 00:06: setting system clock to 2020-12-11 09:12:26 UTC (1607677946)
> 
> So it looks like the e1000e device or driver is the cause.
> (Line 350 in power/main.c has 'TRACE_RESUME(0);'.)
> 
> This was with e1000e compiled into the kernel (as I wanted to use netconsole
> for another issue), but I've also seen the failure with e1000e modular.
> I will now make e1000e modular again and unload it before suspending to see if
> that makes resume stable.
> 
> Note that the eth0 NIC is unused (no cable connected). I use the wireless NIC
> instead.
> 
> Suggestions how to do further tracing or instrumentation would be very welcome.
> 


-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
