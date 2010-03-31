From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 3/6] sysfs: Implement sysfs tagged directory support.
Date: Wed, 31 Mar 2010 00:43:08 -0700
Message-ID: <m11vf12ayb.fsf@fess.ebiederm.org>
References: <m1fx3hk6gw.fsf@fess.ebiederm.org>
	<1269973889-25260-3-git-send-email-ebiederm@xmission.com>
	<4BB2F083.1050803@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Kroah-Hartman <gregkh@suse.de>,
	Kay Sievers <kay.sievers@vrfy.org>,
	linux-kernel@vger.kernel.org,
	Cornelia Huck <cornelia.huck@de.ibm.com>,
	linux-fsdevel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Benjamin LaHaise <bcrl@lhnet.ca>,
	Serge Hallyn <serue@us.ibm.com>, netdev@vger.kernel.org,
	Benjamin Thery <benjamin.thery@bull.net>
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <4BB2F083.1050803@kernel.org> (Tejun Heo's message of "Wed\, 31 Mar 2010 15\:49\:39 +0900")
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tejun Heo <tj@kernel.org> writes:

> Hello, Eric.
>
> On 03/31/2010 03:31 AM, Eric W. Biederman wrote:
>> What this patch does is to add an additional tag field to the
>> sysfs dirent structure.  For directories that should show different
>> contents depending on the context such as /sys/class/net/, and
>> /sys/devices/virtual/net/ this tag field is used to specify the
>> context in which those directories should be visible.  Effectively
>> this is the same as creating multiple distinct directories with
>> the same name but internally to sysfs the result is nicer.
>
> This has become a long running project. :-)
>
> The way to implement partial visibility seems much cleaner now and I
> don't have any objection.  Thanks for cleaning up the whole sysfs and
> implementing this properly.  Unfortunately, I still feel quite
> uncomfortable about how the scope of visibility is determined and how
> deep knowledge about specific namespace implementation seeps down to
> kobject / sysfs layer.  It almost looks like a gross layering
> violation.

The problem is how sysfs and the kobject layer expose things to
userspace.  Maintaining backwards compatibility to userspace in sysfs
while making changes in the rest of the kernel is hard.

Having been through the rest of the kernel and changed every other
significant interface I think I can say that without bias.  

> Is it at all possible to implement it in properly layered manner?
> ie. sysfs providing mechanisms for selective visibility, driver model
> wraps it and exports it and namespace implements namespaces on top of
> those mechanisms?

I think that is roughly what I have.

> I can see that there should be some interaction
> between the driver model and namespaces but I can't see why that
> information should be visible deep down in kobject and sysfs.

At this point you seem to be asking for perfection instead of something
that is merely good enough.  I am open to suggestions for something
better but overall the code is as good as I can get it.  The code
does not impose any real maintenance problems.  The code does not
impose any real performance problems.  The code works.  It is time to
use this stuff, and stop keeping devices out of the kobject layer
because sysfs and the kobject layer can not cope with the reality
of the rest of the kernel.

As for the layering itself.  Down in sysfs there are only two bits
visible.  A void * pointer that in addition to the name is what we use
to define selective visibility.  A context that we capture when we
mount sysfs.  Those bits are fundamental things sysfs needs to do.

Capturing the namespaces of interest when mounting sysfs allows us to
display with different mounts of sysfs what a single mount of sysfs
can not show.

Eric
