From: Benjamin Thery <benjamin.thery@bull.net>
Subject: Re: [PATCH] Fix kobject_rename and !CONFIG_SYSFS v4
Date: Wed, 14 May 2008 11:51:17 +0200
Message-ID: <482AB615.5030000@bull.net>
References: <m163tocw43.fsf_-_@frodo.ebiederm.org>	<20080512220232.GA16914@kroah.com>	<m1prrqbseh.fsf@frodo.ebiederm.org>	<4829A4BD.3020007@bull.net>	<20080513164438.GA31563@kroah.com>	<m18wyeay1q.fsf_-_@frodo.ebiederm.org>	<20080513201602.GA31578@kroah.com>	<m1od7a9bmr.fsf_-_@frodo.ebiederm.org>	<24291087.1210713535895.JavaMail.oracle@acsmt301.oracle.com>	<m1hcd1a48e.fsf_-_@frodo.ebiederm.org>	<20080513220304.b2f5a588.akpm@linux-foundation.org>	<m163th6yz2.fsf@frodo.ebiederm.org> <20080514022059.2fc883b1.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Randy Dunlap <RANDY.DUNLAP@ORACLE.COM>,
	Greg KH <greg@kroah.com>, Al Viro <viro@ftp.linux.org.uk>,
	Greg KH <gregkh@suse.de>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Daniel Lezcano <dlezcano@fr.ibm.com>,
	Pavel Emelyanov <xemul@openvz.org>,
	"Serge E. Hallyn" <serue@us.ibm.com>, Tejun Heo <htejun@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:38066 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752363AbYENJuz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 05:50:55 -0400
In-Reply-To: <20080514022059.2fc883b1.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
> On Wed, 14 May 2008 02:01:37 -0700 ebiederm@xmission.com (Eric W. Biederman) wrote:
> 
>> Andrew Morton <akpm@linux-foundation.org> writes:
>>
>>>> diff --git a/include/linux/sysfs.h b/include/linux/sysfs.h
>>>> index 7858eac..6e61033 100644
>>>> --- a/include/linux/sysfs.h
>>>> +++ b/include/linux/sysfs.h
>>>> @@ -20,6 +20,8 @@
>>>>  struct kobject;
>>>>  struct module;
>>>>  
>>>> +extern int kobject_set_name(struct kobject *kobj, const char *name, ...)
>>>> +			    __attribute__((format(printf, 2, 3)));
>>> Duplicating the kobject_set_name() declaration in sysfs.h is rather a hack.
>> A bit.  It really isn't worse then a struct declaration like struct kobject;
>>
>>> It'd be better to move it into a new header file, included by both
>>> sysfs.h and kobject.h.  Perhaps there are other declarations which can
>>> be moved with it.
>> My gut feel says that sysfs.h should include kobject.h instead of the
>> other way around.

This is also my feeling.
To do this, we need to move "struct attributes" related definitions to 
kboject.h, and fix some .c files that don't include sysfs.h as they 
should (sysfs.h was included indirectly via kojbect.h in these files: eg 
kernel/sched.c, fs/partitions/check.c).

>>
>> However it gets reorganized, it is an entirely separate problem
>> from the one this patch sets out to solve and so should go in
>> a different patch.
>>
> 
> umm, well, actually, it's a problem which your patch introduces, by adding a
> new dependency.
> 
> uninlining sysfs_rename_dir() would be a sensible solution.

It is inlined only when CONFIG_SYSFS=n. When sysfs is enabled 
sysfs_rename_dir() is compiled from fs/sysfs/dir.c

Uninlining it will require us to find an appropriate .c file to put it
in: we can't put it in fs/sysfs/dir.c. It is not built if CONFIG_SYSFS 
is disabled.

-Benjamin

-- 
B e n j a m i n   T h e r y  - BULL/DT/Open Software R&D

    http://www.bull.com
