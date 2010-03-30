From: Kay Sievers <kay.sievers@vrfy.org>
Subject: Re: [PATCH 0/6] tagged sysfs support
Date: Tue, 30 Mar 2010 20:53:25 +0200
Message-ID: <ac3eb2511003301153i43a60720hb015071e2c992199@mail.gmail.com>
References: <m1fx3hk6gw.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Greg Kroah-Hartman <gregkh@suse.de>, Greg KH <greg@kroah.com>,
	linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>,
	Cornelia Huck <cornelia.huck@de.ibm.com>,
	linux-fsdevel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Benjamin LaHaise <bcrl@lhnet.ca>,
	Serge Hallyn <serue@us.ibm.com>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <m1fx3hk6gw.fsf@fess.ebiederm.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 30, 2010 at 20:30, Eric W. Biederman <ebiederm@xmission.com> wrote:
>
> The main short coming of using multiple network namespaces today
> is that only network devices for the primary network namespaces
> can be put in the kobject layer and sysfs.
>
> This is essentially the earlier version of this patchset that was
> reviewed before, just now on top of a version of sysfs that doesn't
> need cleanup patches to support it.

Just to check if we are not in conflict with planned changes, and how
to possibly handle them:

There is the plan and ongoing work to unify classes and buses, export
them at /sys/subsystem in the same layout of the current /sys/bus/.
The decision to export buses and classes as two different things
(which they aren't) is the last major piece in the sysfs layout which
needs to be fixed.

It would mean that /sys/subsystem/net/devices/* would look like
/sys/class/net/* today. But at the /sys/subsystem/net/ directory could
be global network-subsystem-wide control files which would need to be
namespaced too. (The network subsystem does not use subsytem-global
files today, but a bunch of other classes do.)

This could be modeled into the current way of doing sysfs namespaces?
A /sys/bus/<subsystem>/ directory hierarchy would need to be
namespaced, not just a single plain directory with symlinks. Would
that work?

Thanks,
Kay
