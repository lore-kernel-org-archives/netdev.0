From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 14336] New: [Pardus] Soft Lockup Problem with
 Attansic Ethernet Card
Date: Tue, 6 Oct 2009 15:55:02 -0700
Message-ID: <20091006155502.f3fc86d9.akpm@linux-foundation.org>
References: <bug-14336-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	linux-acpi@vger.kernel.org,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	Jie Yang <jie.yang@atheros.com>
To: badibere@gmail.com
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <bug-14336-10286@http.bugzilla.kernel.org/>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Tue, 6 Oct 2009 22:37:13 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=14336
> 
>            Summary: [Pardus] Soft Lockup Problem with Attansic Ethernet
>                     Card
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.30.8
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: badibere@gmail.com
>         Regression: No
> 
> 
> I have soft lockup problem with attansic ethernet card while activating eth0
> interface.
> 
> My ethernet card is 09:00.0 Ethernet controller: Attansic Technology Corp.
> Device 1063 (rev c0)
> 
> If I try to activate eth0 interface while network cable is pluged in, then
> everything freezes.
> 
> If I try to activate eth0 interface while network cable isn't pluged in, then
> no problem. But, if i plug in, again freezes.
> 
> My /var/log/syslog is in attachment.
> 

>From the dmesg output it appears that this card is driven by the atl1c
driver:

Oct  7 00:55:57 baDibere kernel: [  169.943463] atl1c 0000:09:00.0: Unable to allocate MSI interrupt Error: -22
Oct  7 00:55:57 baDibere kernel: [  169.943576] atl1c 0000:09:00.0: atl1c: eth0 NIC Link is Up<100 Mbps Full Duplex>
Oct  7 00:56:22 baDibere kernel: [  194.849361] NVRM: Xid (0001:00): 16, Head 00000000 Count 00003651
Oct  7 00:56:31 baDibere kernel: [  203.849307] NVRM: Xid (0001:00): 16, Head 00000000 Count 00003653
Oct  7 00:56:36 baDibere kernel: [  208.849339] NVRM: Xid (0001:00): 8, Channel 00000003
Oct  7 00:56:41 baDibere kernel: [  213.852320] NVRM: Xid (0001:00): 16, Head 00000000 Count 00003655


The "Unable to allocate MSI interrupt" might be the immediate problem.

Who belongs to MSI interrupt allocation?  PCI?  ACPI?

However the driver does attempt to handle and recover from the MSI
interrupt allocation error so perhaps that's no the cause at all.

