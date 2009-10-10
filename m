From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: PATCH: Network Device Naming mechanism and policy
Date: Fri, 9 Oct 2009 19:44:01 -0700
Message-ID: <20091009194401.036da080@nehalam>
References: <EDA0A4495861324DA2618B4C45DCB3EE5894ED@blrx3m08.blr.amer.dell.com>
	<20091009140000.GA18765@mock.linuxdev.us.dell.com>
	<20091009210909.GA9836@auslistsprd01.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	Narendra_K@dell.com, jordan_hargrave@dell.com
To: Matt Domsch <Matt_Domsch@dell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35123 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756009AbZJJCoo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Oct 2009 22:44:44 -0400
In-Reply-To: <20091009210909.GA9836@auslistsprd01.us.dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 9 Oct 2009 16:09:09 -0500
Matt Domsch <Matt_Domsch@dell.com> wrote:

> On Fri, Oct 09, 2009 at 09:00:01AM -0500, Narendra K wrote:
> > On Fri, Oct 09, 2009 at 07:12:07PM +0530, K, Narendra wrote:
> > > > example udev config:
> > > > SUBSYSTEM=="net",
> > > SYMLINK+="net/by-mac/$sysfs{ifindex}.$sysfs{address}"
> > > 
> > > work as well.  But coupling the ifindex to the MAC address like this
> > > doesn't work.  (In general, coupling any two unrelated attributes when
> > > trying to do persistent names doesn't work.)
> > > 
> > Attaching the latest patch incorporating review comments.
> 
> Same patch, rebased to linux-next.
> 
> By creating character devices for every network device, we can use
> udev to maintain alternate naming policies for devices, including
> additional names for the same device, without interfering with the
> name that the kernel assigns a device.
> 
> This is conditionalized on CONFIG_NET_CDEV.  If enabled (the default),
> device nodes will automatically be created in /dev/netdev/ for each
> network device.  (/dev/net/ is already populated by the tun device.)
> 
> These device nodes are not functional at the moment - open() returns
> -ENOSYS.  Their only purpose is to provide userspace with a kernel
> name to ifindex mapping, in a form that udev can easily manage.
> 
> Signed-off-by: Jordan Hargrave <Jordan_Hargrave@dell.com>
> Signed-off-by: Narendra K <Narendra_K@dell.com>
> Signed-off-by: Matt Domsch <Matt_Domsch@dell.com>

Maybe I'm dense but can't see why having a useless /dev/net/ symlinks
is a good interface choice. Perhaps you should explain the race between
PCI scan and udev in more detail, and why solving it in either of those
places won't work. As it stands you are proposing yet another wart to
the already complex set of network interface API's which has implications
for security as well as increasing the number of possible bugs.

-- 
