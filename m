From: <Jordan_Hargrave@Dell.com>
Subject: RE: PATCH: Network Device Naming mechanism and policy
Date: Tue, 13 Oct 2009 15:00:59 -0500
Message-ID: <5DDAB7BA7BDB58439DD0EED0B8E9A3AE02E8277A@ausx3mpc102.aus.amer.dell.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE5894ED@blrx3m08.blr.amer.dell.com> <20091009140000.GA18765@mock.linuxdev.us.dell.com> <20091013150839.GD32107@ldl.fc.hp.com> <EDA0A4495861324DA2618B4C45DCB3EE58954D@blrx3m08.blr.amer.dell.com> <20091013195117.GA3778@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <dannf@hp.com>, <netdev@vger.kernel.org>,
	<linux-hotplug@vger.kernel.org>, <Matt_Domsch@Dell.com>,
	<Charles_Rose@Dell.com>
To: <greg@kroah.com>, <Narendra_K@Dell.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-class: urn:content-classes:message
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We have developed a mapping library that will convert the user-friendly symlink names to the kernel names necessary for socket ioctls.  All network tools that normally take ethX as argument have been modified to use this mapping library.  Usually it's just a one-line addition when parsing the command line arguments.


--jordan hargrave
Dell Enterprise Linux Engineering



-----Original Message-----
From: Greg KH [mailto:greg@kroah.com]
Sent: Tue 10/13/2009 14:51
To: K, Narendra
Cc: dannf@hp.com; netdev@vger.kernel.org; linux-hotplug@vger.kernel.org; Domsch, Matt; Hargrave, Jordan; Rose, Charles
Subject: Re: PATCH: Network Device Naming mechanism and policy
 
On Tue, Oct 13, 2009 at 10:43:49PM +0530, Narendra_K@Dell.com wrote:
> 
> >> These device nodes are not functional at the moment - open() returns 
> >> -ENOSYS.  Their only purpose is to provide userspace with a kernel 
> >> name to ifindex mapping, in a form that udev can easily manage.
> >
> >If the idea is just to provide a userspace-visible mapping 
> >(and presumably take advantage of udev's infrastructure for 
> >naming) does this need kernel changes? Could this be a 
> >hierarchy under e.g. /etc/udev instead, using plain text 
> >files? It still means we need something like libnetdevname for 
> >apps to do the translation, but I'm not seeing why it matters 
> >how this map is stored. Is there some special property of the 
> >character devices (e.g. uevents) that we're not already 
> >getting with the existing interfaces?
> 
> Yes. The char device by itself doesn't help in any way. But it provides
> a flexible mechanism to provide multiple names for the same device, just
> the way it is for disks.

No, it's quite different than disks in that the symlinks, _and_ the
device nodes do absolutly nothing.  And any reference to a name that is
a symlink will not work with any existing network tool, you will have to
do some kind of lookup to determine which network device you really were
referring to.

These links end up being useless, and confusing, I still don't see how
you can use them for anything.

thanks,

greg k-h

