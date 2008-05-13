From: Greg KH <greg@kroah.com>
Subject: Re: kobject: Fix kobject_rename and !CONFIG_SYSFS
Date: Tue, 13 May 2008 09:44:38 -0700
Message-ID: <20080513164438.GA31563@kroah.com>
References: <m163tocw43.fsf_-_@frodo.ebiederm.org> <20080512220232.GA16914@kroah.com> <m1prrqbseh.fsf@frodo.ebiederm.org> <4829A4BD.3020007@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	Greg KH <gregkh@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, Tejun Heo <htejun@gmail.com>,
	Al Viro <viro@ftp.linux.org.uk>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	"Serge E. Hallyn" <serue@us.ibm.com>,
	Pavel Emelyanov <xemul@openvz.org>, netdev@vger.kernel.org
To: Benjamin Thery <benjamin.thery@bull.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:56754 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751604AbYEMQqQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2008 12:46:16 -0400
Content-Disposition: inline
In-Reply-To: <4829A4BD.3020007@bull.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 13, 2008 at 04:25:01PM +0200, Benjamin Thery wrote:
> Eric W. Biederman wrote:
>> Greg KH <greg@kroah.com> writes:
>>> Eric, Randy Dunlap has found that this patch breaks the build when
>>> CONFIG_SYSFS is not enabled.  Can you please fix it up before I send it
>>> to Linus?
>>>
>>> The exact error is:
>>> In file included from 
>>> /local/linsrc/next-20080509/include/linux/kobject.h:21,
>>>                  from 
>>> /local/linsrc/next-20080509/include/linux/module.h:16,
>>>                  from 
>>> /local/linsrc/next-20080509/include/linux/crypto.h:21,
>>>                  from
>>> /local/linsrc/next-20080509/arch/x86/kernel/asm-offsets_64.c:7,
>>>                  from
>>> /local/linsrc/next-20080509/arch/x86/kernel/asm-offsets.c:4:
>>> /local/linsrc/next-20080509/include/linux/sysfs.h: In function
>>> 'sysfs_rename_dir':
>>> /local/linsrc/next-20080509/include/linux/sysfs.h:142: error: implicit
>>> declaration of function 'kobject_set_name'
>> I will take a look in the morning and see if I can see what is wrong.
>> Which tree was this error against?  I thought I tested this case,
>> and I'm wondering if there might be another patch that is hiding
>> kobject_set_name.
>
> Argh, headers "cross-dependencies":
>
> * linux/kobject.h includes linux/sysfs.h before defining
>   kobject_set_name()
>
> * linux/sysfs.h needs to include linux/kobject.h to find
>   kobject_set_name() definition (for inlined sysfs_rename_dir() when
>   CONFIG_SYSFS=n)
>
>
> sysfs_rename_dir() is only called by kobject.c, kobject_rename().
> I guess this kind of patch is not acceptable to fix the depency?

Ick, no.  I'd rather add a kobject_set_name() function prototype to
sysfs.h in this case, that should remove the error, right?

thanks,

greg k-h
