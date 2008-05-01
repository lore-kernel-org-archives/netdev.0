From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 00/10] sysfs tagged directories
Date: Thu, 01 May 2008 11:34:31 -0700
Message-ID: <m11w4lho08.fsf@frodo.ebiederm.org>
References: <20080429171015.473938697@theryb.frec.bull.fr>
	<20080429173621.GA16625@suse.de>
	<20080429180445.GA18110@sergelap.austin.ibm.com>
	<20080429184151.GA19794@suse.de>
	<20080429193417.GA19282@sergelap.austin.ibm.com>
	<20080501031341.GD4911@suse.de>
	<20080501151051.GB16038@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <gregkh@suse.de>, Benjamin Thery <benjamin.thery@bull.net>,
	linux-kernel@vger.kernel.org, Al Viro <viro@ftp.linux.org.uk>,
	Tejun Heo <htejun@gmail.com>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Pavel Emelyanov <xemul@openvz.org>, netdev@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:40722 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755407AbYEASjk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2008 14:39:40 -0400
In-Reply-To: <20080501151051.GB16038@sergelap.austin.ibm.com> (Serge
	E. Hallyn's message of "Thu, 1 May 2008 10:10:51 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Serge E. Hallyn" <serue@us.ibm.com> writes:

> Quoting Greg KH (gregkh@suse.de):
> Now before moving veth1 to the new netns, we have in the container:
> /sys/class/net:
> lo  sit0
>
> /sys/devices/virtual/net:
> lo  sit0
>
> and after moving veth1, we have in the container:
>
> /sys/class/net:
> lo  sit0  veth1
>
> /sys/devices/virtual/net:
> lo  sit0
>
> In the parent network namespace, veth1 is removed from /sys/class/net
> but remains in /sys/devices/virtual/net.

The symlink is gone by the real directory remains?

> I'm not sure whether this is the renaming bug that Daniel Lezcano's
> patch addresses.  If not (as I suspect) then that clearly needs to be
> fixed.
>
> Benjamin can you play around with this and test it with Daniel's
> patch?

Darn.  It appears we have a regression in this patchset.
That part used to work.

I was thinking of blaming sysfs_rename_link.  But it the
links are fine so it looks more likely that sysfs has morphed once
again and we have  a reference counting issue or something similar.
Yuck. d_move and the other moves should have worked.

>From a purely get the good less controversial parts of this
patchset in.  I suggest we look at patches 7/10 and 8/10 (without
the tag_ops).  And introduce and start using sysfs_delete_link
and sysfs_rename_link.  That code seems pretty stable and is
generally a code reduction all by itself by reducing a common
idiom into a single function.

Eric
