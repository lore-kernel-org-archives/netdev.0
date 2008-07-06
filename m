From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 00/15] sysfs support for namespaces
Date: Sat, 05 Jul 2008 21:42:57 -0700
Message-ID: <m1tzf339ny.fsf@frodo.ebiederm.org>
References: <20080618170729.808539948@theryb.frec.bull.fr>
	<20080618170731.002784342@theryb.frec.bull.fr>
	<485F04E1.70204@gmail.com> <m1y74svtff.fsf@frodo.ebiederm.org>
	<486706C9.9040303@gmail.com> <m18wwmsqdv.fsf@frodo.ebiederm.org>
	<4869D314.5030403@gmail.com> <m1ej6enep7.fsf@frodo.ebiederm.org>
	<486A0751.9080602@gmail.com> <m1wsk5hjm0.fsf@frodo.ebiederm.org>
	<486AF4FA.8020805@gmail.com> <m1ej6d9c2r.fsf@frodo.ebiederm.org>
	<486B060C.7030607@gmail.com> <m14p78s02q.fsf@frodo.ebiederm.org>
	<486C4515.1070007@gmail.com> <m1hcb7o8lv.fsf@frodo.ebiederm.org>
	<486CB051.5000507@fr.ibm.com> <m14p77m9uy.fsf@frodo.ebiederm.org>
	<486CF71F.5090405@gmail.com> <m1y74iiidz.fsf_-_@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Tejun Heo <htejun@gmail.com>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	linux-kernel@vger.kernel.org, Al Viro <viro@ftp.linux.org.uk>,
	Linux Containers <containers@lists.osdl.org>,
	Benjamin Thery <benjamin.thery@bull.net>,
	<netdev@vger.kernel.org>, Cornelia Huck <cornelia.huck@de.ibm.com>
To: Greg Kroah-Hartman <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:51499 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750744AbYGFEvx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jul 2008 00:51:53 -0400
In-Reply-To: <m1y74iiidz.fsf_-_@frodo.ebiederm.org> (Eric W. Biederman's
	message of "Thu, 03 Jul 2008 17:48:40 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> These patches are based off of 2.6.26-rc8 + the -gregkh tree from
> last night.  Hopefully that means they apply -mm -gregkh and
> -linux-next.

A quick update.   My patchset conflicts with the recently added
  driver-core-suppress-sysfs-warnings-for-device_rename.patch

> driver core: Suppress sysfs warnings for device_rename().
> 
> Renaming network devices to an already existing name is not
> something we want sysfs to print a scary warning for, since the
> callers can deal with this correctly. So let's introduce
> sysfs_create_link_nowarn() which gets rid of the common warning.

This patch is unnecessary as that path is never exercised anymore.
as: dev_change_name returns early in the case of a noop rename.

In addition my introduction sysfs_rename_link handles this case
cleanly by first removing the old link and then creating the new
link.  Preventing false positives when the link names are the same.

So it should be safe to drop Cornelia patch without a reoccurance
of scary errors.

Eric


