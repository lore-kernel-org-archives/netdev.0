From: Kay Sievers <kay.sievers@vrfy.org>
Subject: Re: [1/4] DST: Distributed storage documentation.
Date: Mon, 10 Dec 2007 20:44:55 +0100
Message-ID: <1197315895.6399.121.camel@lov.site>
References: <11972872493977@2ka.mipt.ru> <11972872501664@2ka.mipt.ru>
	 <3ae72650712100451h6a84d6cfs9b3a2954c13c4612@mail.gmail.com>
	 <20071210125839.GA16789@2ka.mipt.ru> <1197297108.6399.91.camel@lov.site>
	 <20071210145055.GB7184@2ka.mipt.ru> <1197313348.6399.106.camel@lov.site>
	 <20071210193304.GA24737@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, Greg KH <greg@kroah.com>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20071210193304.GA24737@2ka.mipt.ru>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-12-10 at 22:33 +0300, Evgeniy Polyakov wrote:
> On Mon, Dec 10, 2007 at 08:02:28PM +0100, Kay Sievers (kay.sievers@vrfy.org) wrote:
> > > uganda:~/codes# ls -l /sys/devices/storage/n-0-ffff81003ebc220/
> > > total 0
> > > drwxr-xr-x 2 root root    0 2007-12-10 13:23 power
> > > -r--r--r-- 1 root root 4096 2007-12-10 13:30 size
> > > -r--r--r-- 1 root root 4096 2007-12-10 13:30 start
> > > -r--r--r-- 1 root root 4096 2007-12-10 13:30 type
> > > -rw-r--r-- 1 root root 4096 2007-12-10 13:30 uevent
> > 
> > This is a "struct device" instance without a subsystem (bus/class),
> > right? It will not send an uevent to userspace. Is that intended? Why
> > don't you add them all to the dst bus? 
> 
> I created dst bus for storage devices only, nodes are very different
> objects, and actually they do not need any events from above, but I need
> to put some attributes somewhere, so it is 'empty' device.

Ok.

> > > Actually not - I have to set reference counter to something other than 1
> > > or +/- 1, and thus will have to call kref_get() in a loop, which is a
> > > very ugly step. Is there kref_set() or somethinglike that? At least not
> > > in 2.6.22 what I'm using for now.
> > 
> > Yeah, a loop would look pretty ugly. How about just adding kref_set(),
> > if you need it.
> 
> Well, then it distributed storage will not be able to build as
> standalone module, and kref_set() itself will not be accepted as a single 
> patch, since there are no in-kernel users :)
> It is easily doable though.

Most rules have exceptions. :) Send a patch, so we can see how it looks
like.

> > > > Why don't you use groups for the attributes?
> > > 
> > > For 3-4 attributes it is faster to register them in a loop than typing
> > > another structure :)
> > 
> > Yeah, but if you would need to recover from an error when the creation
> > of a file fails, a group would do the proper "rollback".
> 
> I do not care about such errors - if there is such an error for a file,
> which exports information about type of the node (i.e. string "L" or "R")
> or some other very meaningful info, then system has enough to care about
> instead of this, so dst does not do anything special - it ignores such
> errors :)
> 
> On exit path it will be checked and removed correctly.
> If there will be additional sysfs files, I think group is a good way to
> implement them.
> 
> > > > Why don't you use default attributes for the device, where you get all
> > > > error handling done by the core.
> > > 
> > > What is 'default attributes' and for what devices?
> > > All my sysfs files are so much trivial, so they do not need anything
> > > special and I do not see what is error handling you mentioned.
> > 
> > If all devices of a subsystem (bus/class) are of the same type, you can
> > set a default array of attributes in the "struct bus/class" to be
> > created at every device. If you have multiple types of devices in the
> > same subsytem (bus/class) you can to assign a the "device_type", which
> > has the default attribute group.
> > That way the core will create the files before the event is sent out to
> > userspace, and the files can be access from the event itself. Not sure
> > if that is needed for dst.
> 
> Ok, I see.
> 
> DST right now has 3 types of files - storage files, it is common for
> every storage device; node files, which are the same for every node; and
> per-algorithm private devices - they can be different (actually only
> mirroring algorithm exports something to userspace).
> 
> I think it is possible to use default attributes for storage devices,
> but node device does not have a bus/class, so they will be untouched.

Sounds fine.

Thanks,
Kay

