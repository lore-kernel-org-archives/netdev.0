From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 13856] New: sk_bound_dev_if should be set for
 a socket when using IP_MULITCAST_IF or IP_ADD_MEMBERSHIO
Date: Wed, 29 Jul 2009 12:52:03 -0700
Message-ID: <20090729125203.efbcb7ef.akpm@linux-foundation.org>
References: <bug-13856-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, manlidj@hotmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:45887 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754316AbZG2TwF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2009 15:52:05 -0400
In-Reply-To: <bug-13856-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Tue, 28 Jul 2009 03:42:38 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=13856
> 
>            Summary: sk_bound_dev_if should be set for a socket when using
>                     IP_MULITCAST_IF or IP_ADD_MEMBERSHIO
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.27.7
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: manlidj@hotmail.com
>         Regression: No
> 
> 
> Currently there is no way to tell which interface a multicast packet arrived on
> except by using a raw socket and issuing the SO_BINDTODEVICE option which
> forces the sk_bound_dev_if for the socket to be set.  
> 
> Consider a multi-homed system where a service needs to listen for multicast
> SSDP messages on a number of interfaces.  The system needs to know which
> interface a search message came in on in order to respond with the correct URL. 
> 
> The service needs to join the multicast group on all interfaces.  It must bind
> on INADDR_ANY and then issue the IP_ADD_MEMBERSHIP call.  
> 
> 1. If it uses one socket and joins on all interfaces it will receive mulitcast
> from all interfaces but cannot tell which interface the message came in on
> 
> 2. It it uses a socket per interface each bound on INADDR_ANY and issues
> IP_MULTICAST_IF.  In this case any mulitcast socket, no matter what interface,
> will be forwarded to each socket because sk_bound_dev_if was not set (i.e. 0) -
> see net/ipv4/udp.c [ udp_v4_mcast_next ]
> 
> Suggested solution is to set sk_bound_dev_if when IP_MULTICAST_IF is issued.
> 

