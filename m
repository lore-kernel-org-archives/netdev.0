From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 11620] New: tun device's speed is set to ony
 10mbps
Date: Mon, 22 Sep 2008 16:17:12 -0700
Message-ID: <20080922161712.f4deeda4.akpm@linux-foundation.org>
References: <bug-11620-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, maxk@qualcomm.com
To: netdev@vger.kernel.org, vtun@office.satix.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:34148 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754075AbYIVXRp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 19:17:45 -0400
In-Reply-To: <bug-11620-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Mon, 22 Sep 2008 03:56:08 -0700 (PDT)
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=11620
> 
>            Summary: tun device's speed is set to ony 10mbps
>            Product: Drivers
>            Version: 2.5
>      KernelVersion: 2.6.24-19-generic

2.6.24-19-generic fails

>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: jgarzik@pobox.com
>         ReportedBy: dayasankar@movik.net
> 
> 
> Latest working kernel version:2.6.24-19-generic

2.6.24-19-generic does not fail.

Please clarify: which kernel version failed and whcih version did not?

Thanks.

> Earliest failing kernel version:
> Distribution:
> Hardware Environment:
> Software Environment:linux- ubuntu
> Problem Description: When I open tun device, speed is set to 10mbps and I am
> not able to change it to 100 Mbps
> 
> Steps to reproduce:
> 
> 1) here is ioctl stuff my tun device
> 
>         if (device) strncpy(tun->ifr.ifr_name, device, IFNAMSIZ);
>         tun->ifr.ifr_flags=(flags)?flags:IFF_TUN|IFF_NO_PI;
>         tun->fd=open("/dev/net/tun", O_RDWR);
>         //#ioctl(tun->fd, TUNSETIFF, (void *) &(tun->ifr));
>         ioctl(tun->fd, TUNSETIFF, (void *) &(tun->ifr));
>         ioctl(tun->fd,TUNSETPERSIST,1);
>         ioctl(tun->fd,TUNSETOWNER,500);
>         return (PyObject *)tun;
> 
> 2) Once I create tun device, here are properties of my tun device
> 
> root@daya-desktop:/home/daya/tuntap-0.1# ethtool tun0
> Settings for tun0:
>         Supported ports: [ ]
>         Supported link modes:   
>         Supports auto-negotiation: No
>         Advertised link modes:  Not reported
>         Advertised auto-negotiation: No
>         Speed: 10Mb/s
>         Duplex: Full
>         Port: Twisted Pair
>         PHYAD: 0
>         Transceiver: internal
>         Auto-negotiation: off
>         Current message level: 0xffffffa1 (-95)
>         Link detected: no
> 
> 3) When I tried to change the speed, it is throwing the following error
> 
> root@daya-desktop:/home/daya/tuntap-0.1# ethtool -s tun0 speed 100
> Cannot set new settings: Operation not supported
>   not setting speed
> 
> root@daya-desktop:/home/daya/tuntap-0.1# ifconfig tun0 media 100
> port: SIOCSIFMAP: Operation not supported

