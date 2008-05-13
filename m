From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] Fix kobject_rename and !CONFIG_SYSFS v2
Date: Tue, 13 May 2008 13:43:57 -0700
Message-ID: <m1skwm9boy.fsf@frodo.ebiederm.org>
References: <m163tocw43.fsf_-_@frodo.ebiederm.org>
	<20080512220232.GA16914@kroah.com> <m1prrqbseh.fsf@frodo.ebiederm.org>
	<4829A4BD.3020007@bull.net> <20080513164438.GA31563@kroah.com>
	<m18wyeay1q.fsf_-_@frodo.ebiederm.org>
	<Pine.LNX.4.64.0805131120400.632@shark.he.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Greg KH <greg@kroah.com>,
	Benjamin Thery <benjamin.thery@bull.net>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	Greg KH <gregkh@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, Tejun Heo <htejun@gmail.com>,
	Al Viro <viro@ftp.linux.org.uk>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	"Serge E. Hallyn" <serue@us.ibm.com>,
	Pavel Emelyanov <xemul@openvz.org>, netdev@vger.kernel.org
To: "Randy.Dunlap" <rdunlap@xenotime.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:42112 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758883AbYEMUuV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2008 16:50:21 -0400
In-Reply-To: <Pine.LNX.4.64.0805131120400.632@shark.he.net> (Randy Dunlap's
	message of "Tue, 13 May 2008 11:23:33 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Randy.Dunlap" <rdunlap@xenotime.net> writes:

> On Tue, 13 May 2008, Eric W. Biederman wrote:
>
>> Changelog:
>> v2:	Added a declaration of kboject_set_name to sysfs.h
>> 	so the code actually compiles with !CONFIG_SYSFS.
>> 
>> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
>> ---
>>  Documentation/kobject.txt |    4 ++++
>>  drivers/base/core.c       |    5 +++++
>>  include/linux/sysfs.h     |    4 +++-
>>  lib/kobject.c             |   18 +++++-------------
>>  4 files changed, 17 insertions(+), 14 deletions(-)
>> 
>> diff --git a/Documentation/kobject.txt b/Documentation/kobject.txt
>> index bf3256e..79184b4 100644
>> --- a/Documentation/kobject.txt
>> +++ b/Documentation/kobject.txt
>> @@ -118,6 +118,10 @@ the name of the kobject, call kobject_rename():
>>  
>>      int kobject_rename(struct kobject *kobj, const char *new_name);
>>  
>> +Note kobject_rename does perform any locking or have a solid notion of
>
>                            ^not
>
>> +what names are valid so the provide must provide their own sanity checking
>                                ~~~~~~~
>                                caller
>
>> +and serialization.
>> +
>>  There is a function called kobject_set_name() but that is legacy cruft and
>>  is being removed.  If your code needs to call this function, it is
>>  incorrect and needs to be fixed.


Good catch.

Thanks Randy.

Eric
