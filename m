From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 00/15] sysfs support for namespaces
Date: Mon, 07 Jul 2008 05:22:43 -0700
Message-ID: <m1od59yjcc.fsf@frodo.ebiederm.org>
References: <20080618170729.808539948@theryb.frec.bull.fr>
	<485F04E1.70204@gmail.com> <m1y74svtff.fsf@frodo.ebiederm.org>
	<486706C9.9040303@gmail.com> <m18wwmsqdv.fsf@frodo.ebiederm.org>
	<4869D314.5030403@gmail.com> <m1ej6enep7.fsf@frodo.ebiederm.org>
	<486A0751.9080602@gmail.com> <m1wsk5hjm0.fsf@frodo.ebiederm.org>
	<486AF4FA.8020805@gmail.com> <m1ej6d9c2r.fsf@frodo.ebiederm.org>
	<486B060C.7030607@gmail.com> <m14p78s02q.fsf@frodo.ebiederm.org>
	<486C4515.1070007@gmail.com> <m1hcb7o8lv.fsf@frodo.ebiederm.org>
	<486CB051.5000507@fr.ibm.com> <m14p77m9uy.fsf@frodo.ebiederm.org>
	<486CF71F.5090405@gmail.com> <m1y74iiidz.fsf_-_@frodo.ebiederm.org>
	<m1tzf339ny.fsf@frodo.ebiederm.org>
	<20080707134101.518734a9@gondolin.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Kroah-Hartman <gregkh@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Tejun Heo <htejun@gmail.com>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	linux-kernel@vger.kernel.org, Al Viro <viro@ftp.linux.org.uk>,
	Linux Containers <containers@lists.osdl.org>,
	Benjamin Thery <benjamin.thery@bull.net>,
	<netdev@vger.kernel.org>
To: Cornelia Huck <cornelia.huck@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:32986 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751714AbYGGMbt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 08:31:49 -0400
In-Reply-To: <20080707134101.518734a9@gondolin.boeblingen.de.ibm.com>
	(Cornelia Huck's message of "Mon, 7 Jul 2008 13:41:01 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cornelia Huck <cornelia.huck@de.ibm.com> writes:

> My impression was that the networking folks didn't want any warnings for
> renaming failures, not just not for renaming a device to the same name.

Which would be reasonable.  Because all of the checks have been done
before sysfs is called so if sysfs sees a problem it is a sysfs bug.

>> In addition my introduction sysfs_rename_link handles this case
>> cleanly by first removing the old link and then creating the new
>> link.  Preventing false positives when the link names are the same.
>
> sysfs_rename_link() looks cleaner, I agree.
>
>> 
>> So it should be safe to drop Cornelia patch without a reoccurance
>> of scary errors.
>
> Hm, the description looks badly worded - I unfortunately left the old
> text unchanged when I respun the patch :( The patch re-introduces the
> warning in sysfs_add_one() which had been removed in the meanwhile and
> makes device_rename() use a non-warning version. I still think we want
> a warning for the general case since this is usually caused be some
> problems in the calling code (and the alternative would be to add
> checks to all callers.)

Right.  We just need to get the sysfs paths clean enough that we don't
emit false positives.  I think I have accomplished that for rename.

Eric
