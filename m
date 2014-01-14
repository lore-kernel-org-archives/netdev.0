From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [RFC] sysfs_rename_link() and its usage
Date: Tue, 14 Jan 2014 13:12:10 -0800
Message-ID: <20140114211210.GA28453@kroah.com>
References: <20140114171740.GB1867@redhat.com>
 <20140114182135.GA29296@kroah.com>
 <20140114191208.GA9942@redhat.com>
 <20140114193139.GA3636@kroah.com>
 <20140114210610.GC9942@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	ebiederm@xmission.com
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140114210610.GC9942@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 14, 2014 at 10:06:10PM +0100, Veaceslav Falico wrote:
> On Tue, Jan 14, 2014 at 11:31:39AM -0800, Greg KH wrote:
> >On Tue, Jan 14, 2014 at 08:12:08PM +0100, Veaceslav Falico wrote:
> >>On Tue, Jan 14, 2014 at 10:21:35AM -0800, Greg KH wrote:
> >>>On Tue, Jan 14, 2014 at 06:17:40PM +0100, Veaceslav Falico wrote:
> >>>>Hi,
> >>>>
> >>>>I'm hitting a strange issue and/or I'm completely lost in sysfs internals.
> >>>>
> >>>>Consider having two net_device *a, *b; which are registered normally.
> >>>>Now, to create a link from /sys/class/net/a->name/linkname to b, one should
> >>>>use:
> >>>>
> >>>>sysfs_create_link(&(a->dev.kobj), &(b->dev.kobj), linkname);
> >>>>
> >>>>To remove it, even simpler:
> >>>>
> >>>>sysfs_remove_link(&(a->dev.kobj), linkname);
> >>>>
> >>>>This works like a charm. However, if I want to use (obviously, with the
> >>>>symlink present):
> >>>>
> >>>>sysfs_rename_link(&(a->dev.kobj), &(b->dev.kobj), oldname, newname);
> >>>
> >>>You forgot the namespace option to this call, what kernel version are
> >>>you using here?
> >>
> >>It's git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next ,
> >>3.13-rc6 with some networking patches on top of it.
> >>
> >>And wrt namespace - there are two functions, one is sysfs_rename_link(),
> >>which calls the second one - sysfs_rename_link_ns() with NULL namespace.
> >>
> >>>
> >>>>this fails with:
> >>>>
> >>>>"sysfs: ns invalid in 'a->name' for 'oldname'"
> >>>
> >>>Looks like the namespace for this link isn't valid.
> >>
> >>Yep, though dunno why.
> >
> >Are you testing this with network namespaces enabled?  Perhaps that is
> >why, you need to specify the namespace of the link that you are
> >changing.
> >
> >The fact that the bridge link works is odd to me, I would think that it
> >too needs to specify the network namespace involved, but perhaps bridge
> >objects aren't part of any specific network namespace?  I don't know the
> >bridging code at all, sorry.
> 
> Yep, might be it, will test soon and come back with the results.
> 
> What still bugs me, though, is the logic - why is it possible to remove/add
> without specifying namespace, while it fails to rename it? Maybe the rename
> function should do a better job at detecting the namespace?

Yes, maybe it should, patches are always gladly welcome :)

thanks,

greg k-h
