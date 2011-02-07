From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 28482] New: ADSL PPPOE kernel bug at
 /arch/x86/kernel/pci-nommu.c
Date: Mon, 7 Feb 2011 15:30:07 -0800
Message-ID: <20110207153007.4310783c.akpm@linux-foundation.org>
References: <bug-28482-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: wm666@mail.ru, linux-ide@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:37959 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755079Ab1BGXbD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Feb 2011 18:31:03 -0500
In-Reply-To: <bug-28482-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Mon, 7 Feb 2011 13:24:48 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=28482
> 
>            Summary: ADSL PPPOE kernel bug at /arch/x86/kernel/pci-nommu.c
>            Product: Drivers
>            Version: 2.5

2.6.36.x, actually.

>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org

OK, this is strange.  The BUG trace points very firmly at the ATA code,
but your report attributes the crash to the PPPOE code.  How can this be?

Perhaps the PPPOE code is scribbling on memory which the ata code uses.

If you have more oops traces then it would be useful for us to see them
please.  You could attach them to the bugzilla report and then let us
know via reply-to-all to this email, thanks.



>         ReportedBy: wm666@mail.ru
>         Regression: No
> 
> 
> Created an attachment (id=46712)
>  --> (https://bugzilla.kernel.org/attachment.cgi?id=46712)
> Screenshot
> 
> uname -a
> Linux server 2.6.36-gentoo-r5-sfireman #1 SMP Sun Feb 6 17:34:43 MSK 2011
> x86_64 Intel(R) Core(TM)2 CPU 6400 @ 2.13GHz GenuineIntel GNU/Linux
> 
> lsmod
> xt_CLASSIFY              877  24
> sch_sfq                 5791  4
> sch_htb                14250  1
> xt_limit                1830  2
> xt_state                1143  5
> ipt_addrtype            1865  0
> xt_DSCP                 2059  0
> xt_dscp                 1579  0
> xt_string               1211  0
> xt_owner                1063  0
> xt_NFQUEUE              1565  0
> xt_multiport            1702  6
> xt_mark                 1093  0
> xt_iprange              1456  0
> xt_hashlimit            5797  0
> xt_conntrack            2551  0
> xt_connmark             1629  0
> scsi_wait_scan           679  0
> 
> lspci
> 00:00.0 Host bridge: Intel Corporation 82P965/G965 Memory Controller Hub (rev
> 02)
> 00:01.0 PCI bridge: Intel Corporation 82P965/G965 PCI Express Root Port (rev
> 02)
> 00:1c.0 PCI bridge: Intel Corporation 82801H (ICH8 Family) PCI Express Port 1
> (rev 02)
> 00:1c.5 PCI bridge: Intel Corporation 82801H (ICH8 Family) PCI Express Port 6
> (rev 02)
> 00:1d.0 USB Controller: Intel Corporation 82801H (ICH8 Family) USB UHCI
> Controller #1 (rev 02)
> 00:1d.1 USB Controller: Intel Corporation 82801H (ICH8 Family) USB UHCI
> Controller #2 (rev 02)
> 00:1d.2 USB Controller: Intel Corporation 82801H (ICH8 Family) USB UHCI
> Controller #3 (rev 02)
> 00:1d.3 USB Controller: Intel Corporation Device 2833 (rev 02)
> 00:1d.7 USB Controller: Intel Corporation 82801H (ICH8 Family) USB2 EHCI
> Controller #1 (rev 02)
> 00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev f2)
> 00:1f.0 ISA bridge: Intel Corporation 82801HB/HR (ICH8/R) LPC Interface
> Controller (rev 02)
> 00:1f.2 SATA controller: Intel Corporation 82801HR/HO/HH (ICH8R/DO/DH) 6 port
> SATA AHCI Controller (rev 02)
> 00:1f.3 SMBus: Intel Corporation 82801H (ICH8 Family) SMBus Controller (rev 02)
> 02:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8056 PCI-E
> Gigabit Ethernet Controller (rev 12)
> 03:00.0 VGA compatible controller: nVidia Corporation Device 10c3 (rev a2)
> 03:00.1 Audio device: nVidia Corporation Device 0be3 (rev a1)
> 04:00.0 Multimedia controller: Philips Semiconductors SAA7146 (rev 01)
> 04:02.0 Ethernet controller: D-Link System Inc DGE-530T Gigabit Ethernet
> Adapter (rev 11) (rev 11)
> 04:04.0 Ethernet controller: Marvell Technology Group Ltd. 88E8001 Gigabit
> Ethernet Controller (rev 14)
> 
> kernel bug at /arch/x86/kernel/pci-nommu.c
> 
> how to reproduce:
> I use pppoe(pppd with compiled in kernel module for pppoe)
> gentoo /etc/conf.d/net
> 
> #HOME DOMAIN NAME
> dns_domain_lo="home"
> 
> #LAN
> config_eth0=( "192.168.10.1 netmask 255.255.255.0 brd 192.168.10.255" )
> 
> #WIFI
> config_eth1=( "192.168.0.2 netmask 255.255.255.0 brd 192.168.0.255" )
> 
> #ADSL
> config_eth2=( "192.168.1.2 netmask 255.255.255.0 brd 192.168.1.255" )
> 
> #ADSL Primary
> config_ppp0=(
>         "ppp"
>         "192.168.1.254" #ALIAS
> )
> link_ppp0="eth2"
> plugins_ppp0=( "pppoe" )
> username_ppp0='sfireman'
> password_ppp0='zpres9'
> pppd_ppp0=(
>         "noauth"
>         "defaultroute"
>         "usepeerdns"
>         "holdoff 3"
>         "child-timeout 60"
>         "lcp-echo-interval 15"
>         "lcp-echo-failure 3"
>         noaccomp noccp nobsdcomp nodeflate nopcomp novj novjccomp
> )
> 
> depend_ppp0() {
>     need net.eth2
> }
> 
> #ADSL Statistic only
> config_ppp1=( "ppp" )
> link_ppp1="eth2"
> plugins_ppp1=( "pppoe" )
> username_ppp1='stat'
> password_ppp1='stat'
> pppd_ppp1=(
>         "noauth"
>         "defaultroute"
>         "usepeerdns"
>         "holdoff 3"
>         "child-timeout 60"
>         "lcp-echo-interval 15"
>         "lcp-echo-failure 3"
>         noaccomp noccp nobsdcomp nodeflate nopcomp novj novjccomp
> )
> 
> depend_ppp1() {
>     need net.eth2
> }
> 
> do.: 
> /etc/init.d/net.ppp0 start
> /etc/init.d/net.ppp1 start
> 
> so. bug causes by starting second ppp link, if first already present.
> 
> Bumps! :(
> It's reproduces 100%.
> But stack traces is different.
> Please, fix it.
> 
> P.S. sorry for my ugly english :)

