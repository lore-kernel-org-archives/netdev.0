From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 15474] New: r8169 fails to bring up ethernet
Date: Thu, 18 Mar 2010 12:08:26 -0700
Message-ID: <20100318120826.42a5a5ed.akpm@linux-foundation.org>
References: <bug-15474-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, linux-pci@vger.kernel.org,
	netdev@vger.kernel.org, Francois Romieu <romieu@fr.zoreil.com>,
	rootkit85@yahoo.it
To: Jesse Barnes <jbarnes@virtuousgeek.org>, Tejun Heo <tj@kernel.org>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <bug-15474-10286@http.bugzilla.kernel.org/>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Sun, 7 Mar 2010 23:57:32 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=15474

Thanks for doing the bisection - it really helps.

Guys, this is a 2.6.32 -> 2.6.33 regression.

>            Summary: r8169 fails to bring up ethernet
>            Product: Drivers
>            Version: 2.5
>     Kernel Version: 2.6.33
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: rootkit85@yahoo.it
>         Regression: Yes
> 
> 
> Created an attachment (id=25399)
>  --> (http://bugzilla.kernel.org/attachment.cgi?id=25399)
> System log
> 
> With the release 2.6.33 the kernel can't bring up my ethernet.
> I have found the commit which broke it:
> 
> root@raver:/usr/src/linux-2.6# git bisect good
> ac1aa47b131416a6ff37eb1005a0a1d2541aad6c is the first bad commit
> commit ac1aa47b131416a6ff37eb1005a0a1d2541aad6c
> Author: Jesse Barnes <jbarnes@virtuousgeek.org>
> Date:   Mon Oct 26 13:20:44 2009 -0700
> 
>     PCI: determine CLS more intelligently
> 
>     Till now, CLS has been determined either by arch code or as
>     L1_CACHE_BYTES.  Only x86 and ia64 set CLS explicitly and x86 doesn't
>     always get it right.  On most configurations, the chance is that
>     firmware configures the correct value during boot.
> 
>     This patch makes pci_init() determine CLS by looking at what firmware
>     has configured.  It scans all devices and if all non-zero values
>     agree, the value is used.  If none is configured or there is a
>     disagreement, pci_dfl_cache_line_size is used.  arch can set the dfl
>     value (via PCI_CACHE_LINE_BYTES or pci_dfl_cache_line_size) or
>     override the actual one.
> 
>     ia64, x86 and sparc64 updated to set the default cls instead of the
>     actual one.                                                                 
> 
>     While at it, declare pci_cache_line_size and pci_dfl_cache_line_size        
>     in pci.h and drop private declarations from arch code.                      
> 
>     Signed-off-by: Tejun Heo <tj@kernel.org>                                    
>     Acked-by: David Miller <davem@davemloft.net>                                
>     Acked-by: Greg KH <gregkh@suse.de>                                          
>     Cc: Ingo Molnar <mingo@elte.hu>                                             
>     Cc: Thomas Gleixner <tglx@linutronix.de>                                    
>     Cc: Tony Luck <tony.luck@intel.com>                                         
>     Signed-off-by: Jesse Barnes <jbarnes@virtuousgeek.org>
> 
> :040000 040000 8b20ad60ed3e273b74bfb588dbea6948547e8de1
> 92498585770ca360c2716c0d3c55d5f4a37356a1 M      arch
> :040000 040000 56d1abd61286dd303bb37c2002b699e526988f85
> 3f20bba2d1e107a80a738e3561fc0fa92e0c4024 M      drivers
> :040000 040000 26d85393248c542ca2cea0e3ac4ceabd0ea659aa
> 326cbb98321cd4e490d888f48bc584b3662c8f06 M      include
