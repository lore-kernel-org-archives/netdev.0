From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 10322] New: e1000 is not auto-negotiating to
 1GB full duplex speed even there is 1GB speed availble
Date: Tue, 25 Mar 2008 12:36:54 -0700
Message-ID: <20080325123654.91f80b00.akpm@linux-foundation.org>
References: <bug-10322-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	Auke Kok <auke-jan.h.kok@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: lqs_xting@sohu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:56916 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758398AbYCYThh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2008 15:37:37 -0400
In-Reply-To: <bug-10322-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).


On Tue, 25 Mar 2008 07:29:56 -0700 (PDT)
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=10322
> 
>            Summary: e1000 is not auto-negotiating to 1GB full duplex speed
>                     even there is 1GB speed availble
>            Product: Drivers
>            Version: 2.5
>      KernelVersion: 2.6.23
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: jgarzik@pobox.com
>         ReportedBy: lqs_xting@sohu.com
>                 CC: lqs_xting@sohu.com
> 
> 
> Latest working kernel version: 2.6.23.9
> Earliest failing kernel version: 2.6.21

err, according to this, we had the bug in 2.6.21 and then fixed it in
2.6.23.9, so this is a report of an already fixed bug ;)

Can you please clarify the version numbers here?

> Distribution:
> Hardware Environment: e1000 with 82571 chip
> Software Environment: CentOS 4.5
> Problem Description:
> We have a machine with the e1000(82571) driver which could not detect the
> correct link mode with a switch supports 1000 Mbps/s. I just find that the
> ethtool can't support 10 Mbps/s Half and 1000 Mbps/s Full mode. Therefore, the
> e1000 code should be fixed by add all modes at the 216 lines in
> e1000_ethtool.c. It is as follow:
> 
> hw->autoneg_advertised |= ecmd->advertising |
>                          ADVERTISED_TP |
>                          ADVERTISED_Autoneg;
> 
> 
> Steps to reproduce:
> 1. Add a entry ' ETHTOOL_OPTS="autoneg on" ' in the
> /etc/sysconfig/network-scripts/ifcfg-eth0;
> 2. Run '/etc/init.d/network restart';
> 3. Run 'ethtool eth0', it displays the speed is 100 Mbps/s. But the real link
> mode should be 1000 Mbps/s

