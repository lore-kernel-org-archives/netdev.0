From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] net: allow netdev_wait_allrefs() to run faster
Date: Fri, 30 Oct 2009 17:37:25 -0700
Message-ID: <m1k4ycjt4q.fsf@fess.ebiederm.org>
References: <4ADB55BC.5020107@gmail.com> <20091018182144.GC23395@kvack.org>
	<200910211539.01824.opurdila@ixiacom.com> <4ADF2B57.4030708@gmail.com>
	<20091021165139.GL877@kvack.org> <m1d445yf2x.fsf@fess.ebiederm.org>
	<20091029233848.GV3141@kvack.org> <m1vdhxu01v.fsf@fess.ebiederm.org>
	<20091030143527.GA3141@kvack.org> <m1my38lb0f.fsf@fess.ebiederm.org>
	<20091030235314.GH3141@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Octavian Purdila <opurdila@ixiacom.com>,
	netdev@vger.kernel.org, Cosmin Ratiu <cratiu@ixiacom.com>
To: Benjamin LaHaise <bcrl@lhnet.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:53260 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757449AbZJaAh0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 20:37:26 -0400
In-Reply-To: <20091030235314.GH3141@kvack.org> (Benjamin LaHaise's message of "Fri\, 30 Oct 2009 19\:53\:14 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benjamin LaHaise <bcrl@lhnet.ca> writes:

> On Fri, Oct 30, 2009 at 04:25:52PM -0700, Eric W. Biederman wrote:
>> I realized after sending the message that s_mode in sysfs_dirent is a
>> real size offense.  It is a 16bit field packed in between two longs.
>> So in practice it is possible to move the s_mode  up next to s_flags
>> and add a s_nlink after it both unsigned short and get a cheap sysfs_nlink.
>
> That doesn't work -- the number of directory entries can easily exceed 65535.  
> Current mid range hardware is good enough to terminate 100,000 network 
> interfaces on a single host.

On overflow you nlink becomes zero and you leave it there.  That is how
ondisk filesystems handle that case on directories, and find etc
knows how to deal.

>> Since I'm not quite ready to post my patches.  I will briefly
>> mention what I have in my queue and hopefully get things posted.
>> 
>> I have changes to make it so that sysfs never has to go from
>> the sysfs_dirent to the sysfs inode.  
>
> Ah, interesting.

I have to cleanup sysfs before I merge changes for supporting
multiple network namespaces.

>> I have changes to sys_sysctl() so that it becomes a filesystem lookup
>> under /proc/sys.  Which ultimately makes the code easier to maintain
>> and debug.
>
> That sounds like a much saner approach, but has the wrinkle that procfs can 
> be configured out.

So I will add the dependency.  There are very few serious users of sys_sysctl,
and all of them have been getting a deprecated interface warning every
time they use it for the last several years.

>> Now back to getting things forward ported and ready to post.
>
> I'm looking forward to those changes.  I've been ignoring procfs for the 
> time being by disabling the per-interface entries in the network stack, 
> but there is some desire to be able to enable rp_filter on a per-interface 
> radius config at runtime.  rp_filter has to be disabled across the board 
> on my access routers, as there are several places where assymetric routing 
> is used for performance reasons.

Just out of curiosity does the loose rp_filter mode work for you?

Eric
