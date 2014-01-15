From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC] sysfs_rename_link() and its usage
Date: Wed, 15 Jan 2014 09:16:18 -0500
Message-ID: <20140115141618.GD7950@htj.dyndns.org>
References: <20140114171740.GB1867@redhat.com>
 <20140114182135.GA29296@kroah.com>
 <20140114191208.GA9942@redhat.com>
 <20140114193139.GA3636@kroah.com>
 <20140114210610.GC9942@redhat.com>
 <87iotmc9ic.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Greg KH <gregkh@linuxfoundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f44.google.com ([209.85.128.44]:49850 "EHLO
	mail-qe0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751940AbaAOOQZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 09:16:25 -0500
Content-Disposition: inline
In-Reply-To: <87iotmc9ic.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey, Veaceslav, Eric.

On Tue, Jan 14, 2014 at 05:35:23PM -0800, Eric W. Biederman wrote:
> >>> >>This works like a charm. However, if I want to use (obviously, with the
> >>> >>symlink present):
> >>> >>
> >>> >>sysfs_rename_link(&(a->dev.kobj), &(b->dev.kobj), oldname, newname);
> >>> >
> >>> >You forgot the namespace option to this call, what kernel version are
> >>> >you using here?
> >>>
> >>> It's git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next ,
> >>> 3.13-rc6 with some networking patches on top of it.

Does this work on 3.12?  How about Greg's driver-core-next?  Do you
have a minimal test case that I can use to reproduce the issue?

> sysfs_rename_link was originally written to infer figure everything out
> based on the target device.  Because symlinks only make sense being in
> the same namespace of their devices.  Tejun broke the inference and now
> you are having hard time using the code.

I wouldn't be surprised if I broke it but

> The commit that broke things was:
> 
> commit 4b30ee58ee64c64f59fd876e4afa6ed82caef3a4
> Author: Tejun Heo <tj@kernel.org>
> Date:   Wed Sep 11 22:29:06 2013 -0400
> 
>     sysfs: remove ktype->namespace() invocations in symlink code

I'm not so sure about the above commit.  The warning is from rename
failing to locate the existing node while the above patch updates the
target ns to rename to.  The old_ns part stays the same before and
after the commit.

Veaceslav, please confirm whether the issue is reproducible w/ v3.12.

Thanks.

-- 
tejun
