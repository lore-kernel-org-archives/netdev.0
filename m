From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] Fix kobject_rename and !CONFIG_SYSFS v4
Date: Wed, 14 May 2008 02:01:37 -0700
Message-ID: <m163th6yz2.fsf@frodo.ebiederm.org>
References: <m163tocw43.fsf_-_@frodo.ebiederm.org>
	<20080512220232.GA16914@kroah.com> <m1prrqbseh.fsf@frodo.ebiederm.org>
	<4829A4BD.3020007@bull.net> <20080513164438.GA31563@kroah.com>
	<m18wyeay1q.fsf_-_@frodo.ebiederm.org>
	<20080513201602.GA31578@kroah.com>
	<m1od7a9bmr.fsf_-_@frodo.ebiederm.org>
	<24291087.1210713535895.JavaMail.oracle@acsmt301.oracle.com>
	<m1hcd1a48e.fsf_-_@frodo.ebiederm.org>
	<20080513220304.b2f5a588.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Randy Dunlap <RANDY.DUNLAP@ORACLE.COM>, Greg KH <greg@kroah.com>,
	Al Viro <viro@ftp.linux.org.uk>,
	Benjamin Thery <benjamin.thery@bull.net>,
	Greg KH <gregkh@suse.de>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Daniel Lezcano <dlezcano@fr.ibm.com>,
	Pavel Emelyanov <xemul@openvz.org>,
	"Serge E. Hallyn" <serue@us.ibm.com>, Tejun Heo <htejun@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761018AbYENJKr@vger.kernel.org>
In-Reply-To: <20080513220304.b2f5a588.akpm@linux-foundation.org> (Andrew
	Morton's message of "Tue, 13 May 2008 22:03:04 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton <akpm@linux-foundation.org> writes:

>> diff --git a/include/linux/sysfs.h b/include/linux/sysfs.h
>> index 7858eac..6e61033 100644
>> --- a/include/linux/sysfs.h
>> +++ b/include/linux/sysfs.h
>> @@ -20,6 +20,8 @@
>>  struct kobject;
>>  struct module;
>>  
>> +extern int kobject_set_name(struct kobject *kobj, const char *name, ...)
>> +			    __attribute__((format(printf, 2, 3)));
>
> Duplicating the kobject_set_name() declaration in sysfs.h is rather a hack.
A bit.  It really isn't worse then a struct declaration like struct kobject;

> It'd be better to move it into a new header file, included by both
> sysfs.h and kobject.h.  Perhaps there are other declarations which can
> be moved with it.

My gut feel says that sysfs.h should include kobject.h instead of the
other way around.

However it gets reorganized, it is an entirely separate problem
from the one this patch sets out to solve and so should go in
a different patch.

Eric
