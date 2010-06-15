From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 16187] New: Carrier detection failed in dhcpcd
 when link is up
Date: Tue, 15 Jun 2010 14:24:18 -0700
Message-ID: <20100615142418.f47e8abd.akpm@linux-foundation.org>
References: <bug-16187-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, casteyde.christian@free.fr
To: netdev@vger.kernel.org, Grant Grundler <grundler@parisc-linux.org>,
	Kyle McMartin <kyle@mcmartin.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:38051 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932481Ab0FOVZH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 17:25:07 -0400
In-Reply-To: <bug-16187-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Sat, 12 Jun 2010 15:15:31 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=16187
> 
>            Summary: Carrier detection failed in dhcpcd when link is up
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.35-rc2
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: casteyde.christian@free.fr
>         Regression: Yes
> 
> 
> Created an attachment (id=26742)
>  --> (https://bugzilla.kernel.org/attachment.cgi?id=26742)
> lspci output for 2.6.34 on my computer
> 
> Kernel at least 2.6.35-rc2, 2.6.34 works fine

Seems to be post-2.6.34 breakage in the tulip driver.

> Athlon X2 3000 in 64bits mode
> Slackware 13.1
> "Ethernet controller: ALi Corporation ULi 1689,1573 integrated ethernet. (rev
> 40)" (from lspci)
> 
> Since 2.6.35-rc2 (didn't checked -rc1), dhcpcd hangs fails to detect carrier
> appearance at boot.
> 
> The Slackware network script uses dhcpcd to bring DHCP interfaces up. At boot,
> it seems my network device doesn't have the link up immediatly. dhcpcd tries to
> bring it up, and wait for the carrier. The carrier indeed goes up, but dhcpcd
> gets absolutly no notification of that, and therefore times out.
> 
> logs says that:
> Jun 12 16:53:58 sirius logger: /etc/rc.d/rc.inet1:  /sbin/route add -net
> 127.0.0.0 netmask 255.0.0.0 lo
> Jun 12 16:53:58 sirius logger: /etc/rc.d/rc.inet1:  /sbin/dhcpcd -t 10  eth0
> Jun 12 16:53:58 sirius dhcpcd: version 5.2.2 starting
> Jun 12 16:53:58 sirius kernel: ADDRCONF(NETDEV_UP): eth0: link is not ready
> Jun 12 16:53:58 sirius dhcpcd: eth0: waiting for carrier
> Jun 12 16:54:01 sirius kernel: uli526x: eth0 NIC Link is Up 100 Mbps Full
> duplex
> Jun 12 16:54:01 sirius kernel: ADDRCONF(NETDEV_CHANGE): eth0: link becomes
> ready
> then dhcpcd times out a little later (10 seconds as -t 10 is specified).
> 
> If I use the -K option (no carrier detection), and does ifconfig eth0 up just
> before issueing the dhcpcd command, dhcpcd doesn't wait for the carrier and
> gets a lease correctly.
> 
> Reversely, with the 2.6.34 kernel, dhcpcd indeed gets the link up notification,
> and gets the lease immediatly. In this case, the log says:
> 
> Jun 12 17:04:21 sirius logger: /etc/rc.d/rc.inet1:  /sbin/route add -net
> 127.0.0.0 netmask 255.0.0.0 lo
> Jun 12 17:04:21 sirius logger: /etc/rc.d/rc.inet1:  /sbin/dhcpcd -t 10  eth0
> Jun 12 17:04:22 sirius dhcpcd: version 5.2.2 starting
> Jun 12 17:04:22 sirius kernel: ADDRCONF(NETDEV_UP): eth0: link is not ready
> Jun 12 17:04:22 sirius dhcpcd: eth0: waiting for carrier
> Jun 12 17:04:25 sirius dhcpcd: eth0: carrier acquired
> Jun 12 17:04:25 sirius kernel: uli526x: eth0 NIC Link is Up 100 Mbps Full
> duplex
> Jun 12 17:04:25 sirius kernel: ADDRCONF(NETDEV_CHANGE): eth0: link becomes
> ready
> Jun 12 17:04:25 sirius dhcpcd: eth0: broadcasting for a lease
> Jun 12 17:04:29 sirius dhcpcd: eth0: offered 192.168.1.3 from 192.168.1.1
> Jun 12 17:04:29 sirius dhcpcd: eth0: acknowledged 192.168.1.3 from 192.168.1.1
> Jun 12 17:04:29 sirius dhcpcd: eth0: checking for 192.168.1.3
> Jun 12 17:04:34 sirius dhcpcd: eth0: leased 192.168.1.3 for 864000 seconds
> Jun 12 17:04:34 sirius dhcpcd: forking to background
> 
> As you can see, dhcpcd asks for a lease as soon as the kernel tells it the link
> is up (message "carrier acquired").
> 
> Therefore, I think 2.6.35-rc* notification of carrier is broken, and at least
> it broke dhcpcd way of watching the link.
> 

