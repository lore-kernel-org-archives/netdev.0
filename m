From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 0/10] sysfs network namespace support
Date: Sat, 01 Dec 2007 02:06:58 -0700
Message-ID: <m163zi9425.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tejun Heo <htejun@gmail.com>,
	Linux Containers <containers@lists.osdl.org>,
	<netdev@vger.kernel.org>, cornelia.huck@de.ibm.com,
	stern@rowland.harvard.edu, kay.sievers@vrfy.org,
	<linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
To: Greg Kroah-Hartman <gregkh@suse.de>, Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:35447 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751012AbXLAJJR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2007 04:09:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Now that we have network namespace support merged it is time to
revisit the sysfs support so we can remove the dependency on !SYSFS.

I'm not even trying to base this on any of Tejun's very interesting 
work on sysfs to remove the coupling between kobjects and
sysfs_dirents.  For my objective that just means I would need to
spend several more weeks staring at sysfs trying to figure out
how to get where I am going and iterating several times from yet
another new starting place.  I want to get something working before I
try for anymore perfection.

I don't expect the userspace side of this to ever change which is
close enough to perfect for me.

The bulk of the patches are the changes to allow multiple sysfs
superblocks.

Then comes the tagged directory sysfs support which uses information
captured at mount time to decide which object with which tag will
appear in a directory.

Then the support for renaming and deleting objects where the source
may be ambiguous because of tagging.

Then finally the network namespace support so it is clear how all
of this tied together.

Greg the last patch that enables tagged directory support seems
to make most sense living in your tree, as it lives half in
fs/sysfs/mount.c, and half in net/core/net-sysfs.c and all of
it's dependencies are in Linus tree except for this patchset.

Eric
