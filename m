From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Possible race/deadlock in netdev_unregister
Date: Fri, 28 Jan 2005 15:38:06 -0800
Message-ID: <20050128153806.2c0fd337@dxpl.pdx.osdl.net>
References: <200501282313.30517.daniele@orlandi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Daniele Orlandi <daniele@orlandi.com>
In-Reply-To: <200501282313.30517.daniele@orlandi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 28 Jan 2005 23:13:29 +0100
Daniele Orlandi <daniele@orlandi.com> wrote:

> 
> Hello,
> 
> First of all, please excuse me if this happens to be a bug in my code :)
> Unfortunately I'm still a newbie with netdev and his interactions with 
> netlink, hotplug, etc... please help me understand what's happening and who 
> is wrong.
> 
> The scenario is this:
> 
> - A device driver module (written by me) has two netdevices registered.
> - Another module (written by me, too) provides sockets implementation for the 
> protocol spoken by the device.
> - An application has one socket bound to one netdevice
> - I rmmod the device driver module
> - The exit function in the module calls netdev_unregister
> - The event dispatcher notifies the socket layer that a device is going down
> - The socket is marked errored but the application keeps it open for a while
> - The application ends, the socket is destroyed, the remaining reference to 
> netdevice is released but netdev_unregister keeps sleeping forever with this 
> backtrace:

You are probably self-deadlocking on the netlink mutex (rtnl).
Is your netdevice_notifier handler calling rtnl_lock?
