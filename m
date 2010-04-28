From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 15868] New: Deleting IP address from interface
 doesn't prevent sending a data.
Date: Wed, 28 Apr 2010 07:42:44 -0400
Message-ID: <20100428074244.304683c7.akpm@linux-foundation.org>
References: <bug-15868-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, Yurij.Plotnikov@oktetlabs.ru
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:54369 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754497Ab0D1OpR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 10:45:17 -0400
In-Reply-To: <bug-15868-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Wed, 28 Apr 2010 08:11:02 GMT bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=15868
> 
>            Summary: Deleting IP address from interface doesn't prevent
>                     sending a data.
>            Product: Networking
>            Version: 2.5
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: Yurij.Plotnikov@oktetlabs.ru
>         Regression: No
> 
> 
> Starting from 2.6.26, Linux kernel has strange behavior for the interface with
> two IPv4 addresses.
> 
>  Let A and B are hosts with directly connected interfaces ethA (on host A) and
> ethB (on host B). Let 10.10.0.1/24 and 10.10.0.3/24 addresses are assigned to
> ethA and 10.10.0.2/24 address is assigned to ethB. Let there is established TCP
> connection between host A and host B with sockets sock_A and sock_B that are
> bound to 10.10.0.3 and 10.10.0.2 addresses respectively. Then if someone
> deletes 10.10.0.3 address from ethA interface and after that send some data
> from sock_A socket then the data will be delivered to sock_B socket and someone
> can read it from this socket.
> 
>  There is the same picture for UDP sockets. With previous definitions if there
> are UDP sockets sock_A on host A and sock_B on host B and they are bound to
> 10.10.0.3 and 10.10.0.2 addresses respectively and they are connected to
> 10.10.0.2 and 10.10.0.3 addresses respectively then if someone deletes
> 10.10.0.3 address from ethA interface and after that send some data using
> send() function from sock_A then the data will be delivered to sock_B.
> 
> The data will not be sent in both cases if there are no addresses assigned to
> the interface after address removing.

