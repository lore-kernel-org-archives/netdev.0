From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 0/6] tagged sysfs support
Date: Tue, 30 Mar 2010 23:52:56 -0700
Message-ID: <m1d3yl6kzb.fsf@fess.ebiederm.org>
References: <m1fx3hk6gw.fsf@fess.ebiederm.org>
	<ac3eb2511003301153i43a60720hb015071e2c992199@mail.gmail.com>
	<m14ojxh0mz.fsf@fess.ebiederm.org>
	<s2hac3eb2511003302251rcbae8767ne21e9daf1546c849@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Kroah-Hartman <gregkh@suse.de>, Greg KH <greg@kroah.com>,
	linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>,
	Cornelia Huck <cornelia.huck@de.ibm.com>,
	linux-fsdevel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Benjamin LaHaise <bcrl@lhnet.ca>,
	Serge Hallyn <serue@us.ibm.com>, netdev@vger.kernel.org
To: Kay Sievers <kay.sievers@vrfy.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <s2hac3eb2511003302251rcbae8767ne21e9daf1546c849@mail.gmail.com> (Kay Sievers's message of "Wed\, 31 Mar 2010 07\:51\:49 +0200")
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kay Sievers <kay.sievers@vrfy.org> writes:

> On Wed, Mar 31, 2010 at 01:04, Eric W. Biederman <ebiederm@xmission.com> wrote:
>> Kay Sievers <kay.sievers@vrfy.org> writes:
>
> Yeah, /sys/bus/, which is the only sane layout of the needlessly
> different 3 versions of the same thing (bus, class, block).
>
> /sys/bus/<subsys> can just be a plain symlinks to the
> /sys/subsystem/<subsys> directories.
>
> /sys/class/<subsys> *could* be a symlink to the
> /sys/subsystem/<subsys>/devices/ directory, but we really don't want
> to continue to stupidly mix subsystem-wide control files with device
> lists anymore. The "devices" directory needs to be a strict list of
> devices, not some collection of random stuff, that it is today. :)
>
> So we either leave all the conceptually broken class attributes behind
> us, and put them at the  /sys/subsystem/<subsys>/ level only, or we
> need to create the /sys/class/<subsys>/* stuff all as symlinks like we
> do today. I expect, we have to create /sys/class as we do today.

Ideally we will keep new subsystem attributes from creeping into 
/sys/class/xxxx/ directories.

> Another problem to solve is that sysfs does not allow us to symlink
> regular files, only directories, so we can currently not create the
> class-wide attributes as symlinks to the proper file in
> /sys/subsystem/.

That seems to be part of the everything is a kobject interface, and
all kobjects are directories.  I don't think supporting the symlinks
will be particularly hard, although there are issues to consider with
respect to making the symlinks come and go when the attributes do.

>>
>> I'm not entirely clear on what you are doing but it all sounds like it
>> will fit within what I am doing.
>
> The goal is to unify the 3 needlessly different versions of "device
> lists of the same subsystem". We have /sys/class, /sys/bus,
> /sys/block, and all of them will be unified at /sys/subsystem/ leaving
> the old names as compat links only. Unlike block and class, the
> /sys/subsystem/<subsys> directory can be extended with custom
> subdirectories and files, without mixing random files into device
> lists.

That makes sense.  I took a quick look and /sys/block is already
a compatibility define.   So I don't expect any issues there.

At a practical level there don't appear to be too many class attributes
that will cause problems, but even a couple are enough to be a pain.

> Yeah, it did not makes sense it the first place to mix devices lists
> with global attributes. It's a real mess what people do in sysfs.

I was very disappointed in sysfs the first time I saw someone add writable
attributes.  But sysfs is here now.

Eric
