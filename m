From: Dan Williams <dcbw@redhat.com>
Subject: Re: Who/What is supposed to remove IPv6 address from interface when
 moving from one network to another ?
Date: Thu, 14 Mar 2013 14:48:15 -0500
Message-ID: <1363290495.1643.29.camel@dcbw.foobar.com>
References: <CAF6-1L4=xACZdqvJ6AZL4XkY17N0pC9PnPfNfK9Tk7QB47c1tw@mail.gmail.com>
	 <CAF6-1L5cxguK8tHxjMACZJ8xNmAXLLXwP086eF4_SEctZdiZ3g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lorenzo@google.com
To: Sylvain Munaut <s.munaut@whatever-company.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52229 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751072Ab3CNTre (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Mar 2013 15:47:34 -0400
In-Reply-To: <CAF6-1L5cxguK8tHxjMACZJ8xNmAXLLXwP086eF4_SEctZdiZ3g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-03-14 at 20:33 +0100, Sylvain Munaut wrote:
> Hi,
> 
> 
> In a nutshell, I'm experiencing the same behavior as described here
> http://kerneltrap.org/mailarchive/linux-netdev/2010/10/26/6288280 ...
> but 2.5 years later ...
> 
> When switching network, my interface doesn't necessarily goes down and
> so IPv6 prefixes from my old location are kept, causing issues.
> 
> I read the thread above, but it just seem to "stop" without really a
> solution ...
> 
> So what's the proper thing to do ?  How is it supposed to work ?
> I searched for a while and except for the thread above, I couldn't
> find any reference on whose responsibility it is to cleanup. Given the
> kernel added the address itself, I'd tend to agree with the original
> poster and that the kernel should handle the cleanup.

The old network prefix should have a lifetime, and when that lifetime
has expired, it should be deleted by the kernel.  However, that lifetime
is specified by the IPv6 router on your network, and may be very large.
Thus when you switch networks, if the lifetime of the old prefix has not
expired, the address is not deleted.

A daemon like NetworkManager usually handles this sort of thing for you
by watching for link/carrier events and retriggering the IP
configuration process when you connect to the new network.  The kernel
does not (and shouldn't) trigger anything on carrier change as that's a
site-specific/user-specific policy.

(if you want to trigger it manually, you should be able to run 'ifconfig
eth0 down' and then 'ifconfig eth0 up' when you have connected to the
new network, which clears out the old addresses and then lets the kernel
listen for new router advertisements from the new network).

Dan
