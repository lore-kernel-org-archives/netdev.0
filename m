From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Fix kobject_rename and !CONFIG_SYSFS v4
Date: Wed, 14 May 2008 02:20:59 -0700
Message-ID: <20080514022059.2fc883b1.akpm@linux-foundation.org>
References: <m163tocw43.fsf_-_@frodo.ebiederm.org>
	<20080512220232.GA16914@kroah.com>
	<m1prrqbseh.fsf@frodo.ebiederm.org>
	<4829A4BD.3020007@bull.net>
	<20080513164438.GA31563@kroah.com>
	<m18wyeay1q.fsf_-_@frodo.ebiederm.org>
	<20080513201602.GA31578@kroah.com>
	<m1od7a9bmr.fsf_-_@frodo.ebiederm.org>
	<24291087.1210713535895.JavaMail.oracle@acsmt301.oracle.com>
	<m1hcd1a48e.fsf_-_@frodo.ebiederm.org>
	<20080513220304.b2f5a588.akpm@linux-foundation.org>
	<m163th6yz2.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Randy Dunlap <RANDY.DUNLAP@ORACLE.COM>, Greg KH <greg@kroah.com>,
	Al Viro <viro@ftp.linux.org.uk>,
	Benjamin Thery <benjamin.thery@bull.net>,
	Greg KH <gregkh@suse.de>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Daniel Lezcano <dlezcano@fr.ibm.com>,
	Pavel Emelyanov <xemul@openvz.org>,
	"Serge E. Hallyn" <serue@us.ibm.com>, Tejun Heo <htejun@gmail.com>
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:34746 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753340AbYENJXz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 05:23:55 -0400
In-Reply-To: <m163th6yz2.fsf@frodo.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 May 2008 02:01:37 -0700 ebiederm@xmission.com (Eric W. Biederman) wrote:

> Andrew Morton <akpm@linux-foundation.org> writes:
> 
> >> diff --git a/include/linux/sysfs.h b/include/linux/sysfs.h
> >> index 7858eac..6e61033 100644
> >> --- a/include/linux/sysfs.h
> >> +++ b/include/linux/sysfs.h
> >> @@ -20,6 +20,8 @@
> >>  struct kobject;
> >>  struct module;
> >>  
> >> +extern int kobject_set_name(struct kobject *kobj, const char *name, ...)
> >> +			    __attribute__((format(printf, 2, 3)));
> >
> > Duplicating the kobject_set_name() declaration in sysfs.h is rather a hack.
> A bit.  It really isn't worse then a struct declaration like struct kobject;
> 
> > It'd be better to move it into a new header file, included by both
> > sysfs.h and kobject.h.  Perhaps there are other declarations which can
> > be moved with it.
> 
> My gut feel says that sysfs.h should include kobject.h instead of the
> other way around.
> 
> However it gets reorganized, it is an entirely separate problem
> from the one this patch sets out to solve and so should go in
> a different patch.
> 

umm, well, actually, it's a problem which your patch introduces, by adding a
new dependency.

uninlining sysfs_rename_dir() would be a sensible solution.
