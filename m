From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 14330] New: Kernel
Date: Tue, 13 Oct 2009 19:48:06 -0700
Message-ID: <20091013194806.e1403ca9.akpm@linux-foundation.org>
References: <bug-14330-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, hannes@stressinduktion.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:38522 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753060AbZJNCst (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 22:48:49 -0400
In-Reply-To: <bug-14330-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Tue, 6 Oct 2009 00:16:31 GMT bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=14330
> 
>                URL: NULL pointer dereference with arp_notify and no ip
>                     address
>            Summary: Kernel
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.30.8-64.fc11.x86_64
>           Platform: All
>         OS/Version: Linux
>               Tree: Fedora
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: hannes@stressinduktion.org
>         Regression: No
> 
> 
> A NULL pointer dereference happens if arp_notify is enabled, no ip address is
> set
> and the mac address changes on an interface.
> 
> Steps to reproduce:
> sysctl -w net.ipv4.conf.all.arp_notify=1
> ip a f dev eth0
> ip l s eth0 a 02:00:00:00:00:00
> 
> It seems that in function inetdev_event (net/ipv4/devinet.c:1081) the
> dereference of in_dev->ifa_list->ifa_address blows up because in_dev->ifa_list
> is NULL.
