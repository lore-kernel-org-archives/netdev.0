From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PATCH 12/15] driver core: Implement tagged directory support
 for device classes.
Date: Wed, 16 Jul 2008 14:50:02 +0900
Message-ID: <487D8C0A.9060100@gmail.com>
References: <m18wwiihbn.fsf_-_@frodo.ebiederm.org>	<m14p76ih9a.fsf_-_@frodo.ebiederm.org>	<m1zloyh2mb.fsf_-_@frodo.ebiederm.org>	<m1vdzmh2jr.fsf_-_@frodo.ebiederm.org>	<m1r6aah2hh.fsf_-_@frodo.ebiederm.org>	<m1mykyh2fu.fsf_-_@frodo.ebiederm.org>	<m1hcb6h2d2.fsf_-_@frodo.ebiederm.org> <486DD650.3000804@gmail.com>	<m1tzf593ny.fsf@frodo.ebiederm.org> <486E2C3B.6020603@gmail.com>	<20080704161200.GA1440@suse.de> <m1lk052ptp.fsf@frodo.ebiederm.org>	<487D6A24.9070001@gmail.com> <m17ibmbd39.fsf@frodo.ebiederm.org>
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
Received: from ti-out-0910.google.com ([209.85.142.187]:19473 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751090AbYGPFug (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 01:50:36 -0400
Received: by ti-out-0910.google.com with SMTP id b6so2869690tic.23
        for <netdev@vger.kernel.org>; Tue, 15 Jul 2008 22:50:33 -0700 (PDT)
In-Reply-To: <m17ibmbd39.fsf@frodo.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Eric W. Biederman wrote:
>> Eric, with the multiple superblocks, sysfs now uses inode from the
>> default sysfs_sb with dentries from other sb's.  Is this okay?  Are
>> there any other filesystems which do this?
> 
> I don't know of any other filesystems where this unique challenge arises.
> /proc almost qualifies but it never needs to be modified.
> 
> It is certainly ok to go from multiple dentries to a single inode.
> I'm trying to remember why I choose to do that.  I think both because it simplifies
> the locking and keeps us more efficient in the icache.

It's a bit scary tho.  Working inode->i_dentry or dentry->d_alias
crosses multiple sb's.  sysfs isn't too greedy about dcache/icache.
Only open files and directories hold them and only single copy of
sysfs_dirent is there for most nodes.  Wouldn't it be better to stay on
the safer side and use separate inode hierarchy?

Thanks.

-- 
tejun
