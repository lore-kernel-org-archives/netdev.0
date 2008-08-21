From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/8] Revert "netns: Fix device renaming for sysfs"
Date: Wed, 20 Aug 2008 23:47:08 -0700 (PDT)
Message-ID: <20080820.234708.193699562.davem@davemloft.net>
References: <m18wuq27uj.fsf_-_@frodo.ebiederm.org>
	<m14p5e27tb.fsf_-_@frodo.ebiederm.org>
	<m1vdxuzxco.fsf_-_@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greg@kroah.com, gregkh@suse.de, akpm@linux-foundation.org,
	htejun@gmail.com, dlezcano@fr.ibm.com,
	linux-kernel@vger.kernel.org, viro@ftp.linux.org.uk,
	containers@lists.osdl.org, benjamin.thery@bull.net,
	netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54266
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757728AbYHUGrJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 02:47:09 -0400
In-Reply-To: <m1vdxuzxco.fsf_-_@frodo.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Wed, 20 Aug 2008 23:38:31 -0700

> 
> This reverts commit aaf8cdc34ddba08122f02217d9d684e2f9f5d575.
> 
> Drivers like the ipw2100 call device_create_group when they
> are initialized and device_remove_group when they are shutdown.
> Moving them between namespaces deletes their sysfs groups early.
> 
> In particular the following call chain results.
> netdev_unregister_kobject -> device_del -> kobject_del -> sysfs_remove_dir
> With sysfs_remove_dir recursively deleting all of it's subdirectories,
> and nothing adding them back.
> 
> Ouch!
> 
> Therefore we need to call something that ultimate calls sysfs_mv_dir
> as that sysfs function can move sysfs directories between namespaces
> without deleting their subdirectories or their contents.   Allowing
> us to avoid placing extra boiler plate into every driver that does
> something interesting with sysfs.
> 
> Currently the function that provides that capability is device_rename.
> That is the code works without nasty side effects as originally written.
> 
> So remove the misguided fix for moving devices between namespaces.  The
> bug in the kobject layer that inspired it has now been recognized and
> fixed.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Acked-by: David S. Miller <davem@davemloft.net>
