From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Fix kobject_rename and !CONFIG_SYSFS v4
Date: Wed, 14 May 2008 02:56:12 -0700
Message-ID: <20080514025612.914a05fe.akpm@linux-foundation.org>
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
	<20080514022059.2fc883b1.akpm@linux-foundation.org>
	<482AB615.5030000@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Randy Dunlap <RANDY.DUNLAP@ORACLE.COM>,
	Greg KH <greg@kroah.com>, Al Viro <viro@ftp.linux.org.uk>,
	Greg KH <gregkh@suse.de>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Daniel Lezcano <dlezcano@fr.ibm.com>,
	Pavel Emelyanov <xemul@openvz.org>,
	"Serge E. Hallyn" <serue@us.ibm.com>, Tejun Heo <htejun@gmail.com>
To: Benjamin Thery <benjamin.thery@bull.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:60023 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753059AbYENJ52 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 05:57:28 -0400
In-Reply-To: <482AB615.5030000@bull.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 May 2008 11:51:17 +0200 Benjamin Thery <benjamin.thery@bull.net> wrote:

> > uninlining sysfs_rename_dir() would be a sensible solution.
> 
> It is inlined only when CONFIG_SYSFS=n. When sysfs is enabled 
> sysfs_rename_dir() is compiled from fs/sysfs/dir.c
> 
> Uninlining it will require us to find an appropriate .c file to put it
> in: we can't put it in fs/sysfs/dir.c. It is not built if CONFIG_SYSFS 
> is disabled.

Well yes, that's the problem.  I stuck it in lib/kobject.c but ugh.

I guess we could make it a macro and quickly run away.
