From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] tun driver use private linked list.
Date: Tue, 12 Aug 2003 10:02:59 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030812100259.7d557bf3.shemminger@osdl.org>
References: <20030808113404.0e9e1e6d.shemminger@osdl.org>
	<200308051630.28552.bellucda@tiscali.it>
	<20030805090647.691daa7e.shemminger@osdl.org>
	<200308051910.55823.bellucda@tiscali.it>
	<20030807154524.4794ad45.shemminger@osdl.org>
	<20030807155901.49f1a424.davem@redhat.com>
	<20030808113404.0e9e1e6d.shemminger@osdl.org>
	<5.1.0.14.2.20030812092213.08dc6ea0@unixmail.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Max Krasnyansky <maxk@qualcomm.com>
In-Reply-To: <5.1.0.14.2.20030812092213.08dc6ea0@unixmail.qualcomm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 12 Aug 2003 09:48:50 -0700
Max Krasnyansky <maxk@qualcomm.com> wrote:

> At 01:18 AM 8/9/2003, David S. Miller wrote:
> >On Fri, 8 Aug 2003 11:34:04 -0700
> >Stephen Hemminger <shemminger@osdl.org> wrote:
> >
> >> Less grotty version, applies over earlier patch.
> >>       - keep a private list.  
> >>       - fix debug format strings.
> >>       - drop the name entry in the private data structure since it already
> >>         has a pointer to netdev that has name.
> >
> >Applied, thanks for following up on this Stephen.
> 
> Folks,
> 
> Sorry for jumping in late. 
> I didn't implement cleanup logic in module_exit() because TUN module is not supposed 
> to be unloaded if it has network devices, _even if those devices are down_.
> TUN registers net device only when user application asks for it.
>         fd = open("/dev/net/tun") -> ioctl(fd, CREATE_TUN_DEV) -> read(fd)/write(fd);
> Net device must not be destroyed while fd is open.
> 
> So instead of cleaning up in tun_module_exit() we should fix misc driver to do refcounting 
> for misc devices so that we could bump ref count for tun driver when application creates
> net device.

Not necessary to change anything.  If user process has /dev/net/tun open, then the owner
field in the fops causes the module reference count to correctly increment.  Verified this
and it works.  The issue is that it is possible to create TUN devices with TUN_PERSIST
set and they have to be cleaned up upon. module_exit.

The patch works as expected.
