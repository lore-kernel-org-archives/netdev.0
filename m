From: Stefan Richter <stefanr-MtYdepGKPcBMYopoZt5u/LNAH6kLmebB@public.gmane.org>
Subject: Re: 2.6.30-rc6: Reported regressions from 2.6.29
Date: Sun, 17 May 2009 14:56:23 +0200
Message-ID: <4A100977.1070506@s5r6.in-berlin.de>
References: <_AjETDMbIoL.A.DcH.RYzDKB@chimera> <20090517073327.GC1583@elte.hu> <200905171234.23436.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Martin Bammer <mrb74-RbZlAiThDcE@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Natalie Protasevich <protasnb-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Jeff Mahoney <jeffm-IBi9RG/b67k@public.gmane.org>
To: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200905171234.23436.rjw-KKrjLPT3xs0@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Rafael J. Wysocki wrote:
> On Sunday 17 May 2009, Ingo Molnar wrote:
>> * Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org> wrote:
>>> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13321
>>> Subject		: kernel crash with NULL pointer when boot
>>> Submitter	: Martin Bammer <mrb74-RbZlAiThDcE@public.gmane.org>
>>> Date		: 2009-05-16 12:37 (1 days old)
>>> References	: http://lkml.org/lkml/2009/5/16/100
>> that crash is in reiserfs_for_each_xattr(), during sys_unlink()'s 
>> xattr teardown.
>>
>> There's been a good deal of reiserfs changes in this cycle - some 
>> touch the xattr code as well. Some of them fairly late in the cycle,

(Also, the bug is reportedly a post -rc5 regression.)

>> in the last two weeks:
>>
>>  earth4:~/tip> gll v2.6.29..linus --since=two-weeks-ago fs/reiserfs/
>>  2a32ceb: Fix races around the access to ->s_options
>>  677c9b2: reiserfs: remove privroot hiding in lookup
>>  b82bb72: reiserfs: dont associate security.* with xattr files
>>  ab17c4f: reiserfs: fixup xattr_root caching
>>  edcc37a: Always lookup priv_root on reiserfs mount and keep it
>>  5a6059c: reiserfs: Expand i_mutex to enclose lookup_one_len
>>
>> Martin, you could try a blind revert of say ... ab17c4f, which looks 
>> the most suspect and which is also a rather large commit.
>>
>> Or/and you could try a bisect - perhaps accelerated via:
>>
>>    git bisect start fs/reiserfs/
> 
> I think there's a fix already for this in the works, but it hasn't been merged
> yet.  It looks like Jeff has just posted some reiserfs fixes. :-)

I'd say Martin should try Jeff's pending patches before a revert or 
before starting a bisection.  Either apply them from 
http://lkml.org/lkml/2009/5/17/6, or pull from
  git://git.kernel.org/pub/scm/linux/kernel/git/viro/vfs-2.6.git for-next
or wait for them to appear in Linus' tree...

I for one didn't test the post v2.6.30-rc5 changes to reiserfs, but I 
did try them _together_ with the four pending patches on a system with 
reiserfs root filesystem and extended attributes disabled in the config. 
Everything is fine here after almost a week uptime.
-- 
Stefan Richter
-=====-=-=== -=-= -==-=
http://arcgraph.de/sr/
