From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 9806] New: (tun dev) Impossible to deassert
 IFF_ONE_QUEUE or IFF_NO_PI
Date: Thu, 24 Jan 2008 00:33:56 -0800
Message-ID: <20080124003356.ec51432a.akpm@linux-foundation.org>
References: <bug-9806-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, maxk@qualcomm.com,
	vtun@office.satix.net, netdev@vger.kernel.org
To: nwfilardo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:42362 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752663AbYAXIeb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2008 03:34:31 -0500
In-Reply-To: <bug-9806-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Wed, 23 Jan 2008 13:13:13 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:
> http://bugzilla.kernel.org/show_bug.cgi?id=9806
> 
>            Summary: (tun dev) Impossible to deassert IFF_ONE_QUEUE or
>                     IFF_NO_PI
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
>         ReportedBy: nwfilardo@gmail.com
> 
> 
> Problem Description:
> 
> The TUN/TAP driver only permits one-way transitions of IFF_NO_PI or
> IFF_ONE_QUEUE during the lifetime of a tap/tun interface.  Note that
> tun_set_iff contains
> 
>  541         if (ifr->ifr_flags & IFF_NO_PI)
>  542                 tun->flags |= TUN_NO_PI;
>  543 
>  544         if (ifr->ifr_flags & IFF_ONE_QUEUE)
>  545                 tun->flags |= TUN_ONE_QUEUE;
> 
> This is easily fixed by adding else branches which clear these bits.
> 
> Steps to reproduce:
> 
> This is easily reproduced by setting an interface persistant using tunctl then
> attempting to open it as IFF_TAP or IFF_TUN, without asserting the IFF_NO_PI
> flag.  The ioctl() will succeed and the ifr.flags word is not modified, but the
> interface remains in IFF_NO_PI mode (as it was set by tunctl).
> 

Thanks.   Could you please submit the patch via email?  Send it to
all recipients of this email.

