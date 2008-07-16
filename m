From: Tejun Heo <teheo@suse.de>
Subject: Re: [PATCH 12/15] driver core: Implement tagged directory support
 for device classes.
Date: Wed, 16 Jul 2008 16:02:36 +0900
Message-ID: <487D9D0C.3060105@suse.de>
References: <m18wwiihbn.fsf_-_@frodo.ebiederm.org>	<m14p76ih9a.fsf_-_@frodo.ebiederm.org>	<m1zloyh2mb.fsf_-_@frodo.ebiederm.org>	<m1vdzmh2jr.fsf_-_@frodo.ebiederm.org>	<m1r6aah2hh.fsf_-_@frodo.ebiederm.org>	<m1mykyh2fu.fsf_-_@frodo.ebiederm.org>	<m1hcb6h2d2.fsf_-_@frodo.ebiederm.org> <486DD650.3000804@gmail.com>	<m1tzf593ny.fsf@frodo.ebiederm.org> <486E2C3B.6020603@gmail.com>	<20080704161200.GA1440@suse.de> <m1lk052ptp.fsf@frodo.ebiederm.org>	<487D6A24.9070001@gmail.com> <m17ibmbd39.fsf@frodo.ebiederm.org>	<487D8C0A.9060100@gmail.com> <m11w1u9w5j.fsf@frodo.ebiederm.org> <487D99C7.708@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Greg KH <gregkh@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	linux-kernel@vger.kernel.org, Al Viro <viro@ftp.linux.org.uk>,
	Linux Containers <containers@lists.osdl.org>,
	Benjamin Thery <benjamin.thery@bull.net>,
	netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:33097 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752034AbYGPHDM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jul 2008 03:03:12 -0400
In-Reply-To: <487D99C7.708@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tejun Heo wrote:
> Hello, Eric.
> 
> Eric W. Biederman wrote:
>> Tejun Heo <htejun@gmail.com> writes:
>>
>>> It's a bit scary tho.  Working inode->i_dentry or dentry->d_alias
>>> crosses multiple sb's.  sysfs isn't too greedy about dcache/icache.
>>> Only open files and directories hold them and only single copy of
>>> sysfs_dirent is there for most nodes.  Wouldn't it be better to stay on
>>> the safer side and use separate inode hierarchy?
>> To do that I believe we would need to ensure sysfs does not use 
>> the inode->i_mutex lock except to keep the VFS layer out.  Allowing us
>> to safely change the directory structure, without holding it.
> 
> I don't think sysfs is depending on i_mutex anymore but I need to go
> through the code to make sure.
> 
>> You raise a good point about inode->i_dentry and dentry->d_alias.
>> Generally they are used by fat like filesystems but I am starting to
>> see uses in generic pieces of code.  I don't see any problems today
>> but yes it would be good to do the refactoring to allow us to duplicate
>> the inodes. 
> 
> Yeah, I can't spot any place which can cause actual problem yet but it's
> still scary as we're breaking a vfs assumption and even if it's not a
> problem now, future seemingly unrelated changes can break things subtly.

Okay, one small problem spotted.  It seems invalidate_inodes() can fail
which will make generic_shutdown_super() complain.  It's not a fatal
failure tho.

-- 
tejun
