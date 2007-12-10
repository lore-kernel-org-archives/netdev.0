From: Kay Sievers <kay.sievers@vrfy.org>
Subject: Re: [1/4] DST: Distributed storage documentation.
Date: Mon, 10 Dec 2007 20:02:28 +0100
Message-ID: <1197313348.6399.106.camel@lov.site>
References: <11972872493977@2ka.mipt.ru> <11972872501664@2ka.mipt.ru>
	 <3ae72650712100451h6a84d6cfs9b3a2954c13c4612@mail.gmail.com>
	 <20071210125839.GA16789@2ka.mipt.ru> <1197297108.6399.91.camel@lov.site>
	 <20071210145055.GB7184@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, Greg KH <greg@kroah.com>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20071210145055.GB7184@2ka.mipt.ru>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-12-10 at 17:50 +0300, Evgeniy Polyakov wrote:
> On Mon, Dec 10, 2007 at 03:31:48PM +0100, Kay Sievers (kay.sievers@vrfy.org) wrote:
> > > I meant that for each new device, it will be placed into
> > > /sys/devices/its_name, but it can also be accessed via
> > > /sys/bus/dst/devices/
> > 
> > Still, it looks like a path. :)
> > 
> > Please don't reference any device directly with a /sys/devices/ path.
> > You have to use the subsystem links to the devices
> > in /sys/bus/dst/devices/. Devices are free to move around
> > in /sys/devices, even during runtime. Yours don't do, but anyway, please
> > remove all mentioning of direct access to /sys/devices/.
> 
> Ok, I will update documentation to reference /sys/bus/dst/devices
> instead of /sys/devices

Great, thanks!

> > Btw, where is the top-level /sys/devices/storage/ coming from? I don't
> > see that in the code. We don't accept any new "virtual parents" here.
> >
> > Your devices will automatically appear in /sys/devices/virtual/dst/, and
> > not below your own parent. But that path does not matter anyway, because
> > you should only access them from the /sys/bus/dst/devices/ directory.
> > 
> > And in general please don't claim generic names like "storage" in any
> > namespace for a very specific subsystem like this.
> 
> It is not a parent - it is an example for device called 'storage', if it
> will be called 'testing', then path will be /sys/devices/testing or more
> correct /sys/bus/dst/devices/testing :)

Ah, I see.

> > > It is 'dst' bus.
> > > 
> > > uganda:~/codes# ls -la /sys/devices/staorge/
> > > total 0
> > > drwxr-xr-x 4 root root    0 2007-12-10 11:46 .
> > > drwxr-xr-x 9 root root    0 2007-12-10 11:46 ..
> > > -r--r--r-- 1 root root 4096 2007-12-10 11:46 alg
> > > lrwxrwxrwx 1 root root    0 2007-12-10 11:46 bus -> ../../bus/dst
> > > drwxr-xr-x 3 root root    0 2007-12-10 11:46 n-0-ffff81003e24117
> > > -r--r--r-- 1 root root 4096 2007-12-10 11:46 name
> > > -r--r--r-- 1 root root 4096 2007-12-10 11:46 nodes
> > > drwxr-xr-x 2 root root    0 2007-12-10 11:46 power
> > > -rw-r--r-- 1 root root 4096 2007-12-10 11:46 remove_all_nodes
> > > lrwxrwxrwx 1 root root    0 2007-12-10 11:46 subsystem -> ../../bus/dst
> > > -rw-r--r-- 1 root root 4096 2007-12-10 11:46 uevent
> > 
> > Ok, how does:
> >   ls -l /sys/devices/storage/n-0-ffff81003e24117
> > look?
> 
> uganda:~/codes# ls -l /sys/devices/storage/n-0-ffff81003ebc220/
> total 0
> drwxr-xr-x 2 root root    0 2007-12-10 13:23 power
> -r--r--r-- 1 root root 4096 2007-12-10 13:30 size
> -r--r--r-- 1 root root 4096 2007-12-10 13:30 start
> -r--r--r-- 1 root root 4096 2007-12-10 13:30 type
> -rw-r--r-- 1 root root 4096 2007-12-10 13:30 uevent

This is a "struct device" instance without a subsystem (bus/class),
right? It will not send an uevent to userspace. Is that intended? Why
don't you add them all to the dst bus? 

> > > uganda:~/codes# ls -l /sys/bus/dst/
> > > total 0
> > > drwxr-xr-x 2 root root    0 2007-12-10 09:52 devices
> > > drwxr-xr-x 2 root root    0 2007-12-10 09:52 drivers
> > > -rw-r--r-- 1 root root 4096 2007-12-10 11:46 drivers_autoprobe
> > > --w------- 1 root root 4096 2007-12-10 11:46 drivers_probe
> > 
> > How does:
> >   ls -l /sys/bus/dst/devices
> > look?
> 
> uganda:~/codes# ls -la /sys/bus/dst/devices/
> total 0
> drwxr-xr-x 2 root root 0 2007-12-10 13:30 .
> drwxr-xr-x 4 root root 0 2007-12-10 13:22 ..
> lrwxrwxrwx 1 root root 0 2007-12-10 13:30 storage -> ../../../devices/storage
> 
> Here 'storage' is just a name for device called 'storage', it can be
> anything else.

Fine.

> > Further questions:
> > Why do you do your own refcounting instead of using kref?
> 
> That's because I always used atomic operations as a reference counters
> and did not tried krefs :)
> They are the same actually (module tricky arches where smp_mb_* are
> required), so I can replace them in the next release.

On Mon, 2007-12-10 at 18:12 +0300, Evgeniy Polyakov wrote:
> Actually not - I have to set reference counter to something other than 1
> or +/- 1, and thus will have to call kref_get() in a loop, which is a
> very ugly step. Is there kref_set() or somethinglike that? At least not
> in 2.6.22 what I'm using for now.

Yeah, a loop would look pretty ugly. How about just adding kref_set(),
if you need it.

> > Why don't you use groups for the attributes?
> 
> For 3-4 attributes it is faster to register them in a loop than typing
> another structure :)

Yeah, but if you would need to recover from an error when the creation
of a file fails, a group would do the proper "rollback".

> > Why don't you use default attributes for the device, where you get all
> > error handling done by the core.
> 
> What is 'default attributes' and for what devices?
> All my sysfs files are so much trivial, so they do not need anything
> special and I do not see what is error handling you mentioned.

If all devices of a subsystem (bus/class) are of the same type, you can
set a default array of attributes in the "struct bus/class" to be
created at every device. If you have multiple types of devices in the
same subsytem (bus/class) you can to assign a the "device_type", which
has the default attribute group.
That way the core will create the files before the event is sent out to
userspace, and the files can be access from the event itself. Not sure
if that is needed for dst.

Thanks,
Kay

