From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: PATCH: Network Device Naming mechanism and policy
Date: Fri, 9 Oct 2009 09:12:47 -0700
Message-ID: <20091009091247.0a9b60cb@nehalam>
References: <EDA0A4495861324DA2618B4C45DCB3EE5894F6@blrx3m08.blr.amer.dell.com>
	<20091009160442.GA21371@mock.linuxdev.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	matt_domsch@dell.com, jordan_hargrave@dell.com
To: Narendra K <Narendra_K@dell.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <20091009160442.GA21371@mock.linuxdev.us.dell.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 9 Oct 2009 11:04:43 -0500
Narendra K <Narendra_K@dell.com> wrote:

> On Fri, Oct 09, 2009 at 09:22:19PM +0530, K, Narendra wrote:
> > Jordan_Hargrave@Dell.com wrote:
> > > example udev config:
> > > SUBSYSTEM=="net",
> > SYMLINK+="net/by-mac/$sysfs{ifindex}.$sysfs{address}"
> > work as well.  But coupling the ifindex to the MAC address like this
> > doesn't work.  (In general, coupling any two unrelated attributes when
> > trying to do persistent names doesn't work.)
> > 
> Attaching the latest patch incorporating review comments.
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

What happens if interface is renamed by either networking API:
  ip li set dev eth0 name eth-renamed-by-me
or via
   mv /dev/net/eth0 /dev/net/eth-renamed-by-user
or if both are done at same time (what is locking model?)
