From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] post-sysfs netdev cleanup
Date: Tue, 27 May 2003 09:51:29 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030527095129.4bddbc51.shemminger@osdl.org>
References: <3ECD6E2D.5090000@rogers.com>
	<20030522.174415.28799441.davem@redhat.com>
	<3ECEB317.5020407@osdl.org>
	<20030525.192417.102551586.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: muizelaar@rogers.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030525.192417.102551586.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 25 May 2003 19:24:17 -0700 (PDT)
"David S. Miller" <davem@redhat.com> wrote:

>    From: Stephen Hemminger <shemminger@osdl.org>
>    Date: Fri, 23 May 2003 16:47:35 -0700
> 
>    Seems like a good idea too.
>    
> Ok, great.
> 
> Stephen, I think we need to find a way to put the device
> registration call outside of the RTNL semaphore.  I removed
> in the unregister case, but to be complete we have to push it out in
> the register path too.
> 
> The reason for all of these issues is that link_watch grabs the RTNL
> semaphore, and this runs via keventd.  Thus, trying to invoke any
> usermode helper (/sbin/hotplug etc.) while holding the RTNL semaphore
> can deadlock.

There needs to be some locking in the registration path doesn't there
to prevent two calls to register the same name and other possible conflicts.
So do you want to use dev_base lock or some other locking?
