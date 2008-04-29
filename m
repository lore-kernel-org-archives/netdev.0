From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 00/10] sysfs tagged directories
Date: Tue, 29 Apr 2008 12:14:21 -0700
Message-ID: <m1d4o83242.fsf@frodo.ebiederm.org>
References: <20080429171015.473938697@theryb.frec.bull.fr>
	<20080429173621.GA16625@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benjamin Thery <benjamin.thery@bull.net>,
	linux-kernel@vger.kernel.org, Tejun Heo <htejun@gmail.com>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	"Serge E. Hallyn" <serue@us.ibm.com>,
	Pavel Emelyanov <xemul@openvz.org>, netdev@vger.kernel.org
To: Greg KH <gregkh@suse.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762120AbYD2TTx@vger.kernel.org>
In-Reply-To: <20080429173621.GA16625@suse.de> (Greg KH's message of "Tue, 29
	Apr 2008 10:36:21 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Greg KH <gregkh@suse.de> writes:

> On Tue, Apr 29, 2008 at 07:10:15PM +0200, Benjamin Thery wrote:
>> Here is the announcement Eric wrote back in December to introduce his 
>> patchset:
>
> <snip>
>
> Are the objections that Al Viro made to this patchset when it was last
> sent out addressed in this new series?

I'm trying to recall.  Al was nervous when the approach was described
to him but I don't remember him looking at specific patches and
objecting.

There was also an issue about races in sysfs between rename
and unlink that Al brought up, that causes real problems in
at least one piece of code that uses that functionality.  I have been
busy so I don't know if anyone has addressed that issue.  It is
independent but this patchset may make that issue slightly harder
to fix.

If the concern is Al nervousness with respect to locking order
(and that is complex) the only really sane way to fix that is
to dig into the VFS and change the lock ordering so that is 
friendlier to distributed filesystems like sysfs.

This patchset does not introduce any new lock ordering issues
but it may make the existing convolutions we have to go through
to keep the dcache for existing file handles in sync with the
internal sysfs tree more visible.  As of my last posting I am
not aware of any locking problems in the code itself.

Greg I had thought you had dropped the patchset simply because
you got busy.  I know it languished for a long time because of
that.

Eric
