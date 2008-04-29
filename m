From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 00/10] sysfs tagged directories
Date: Tue, 29 Apr 2008 13:10:06 -0700
Message-ID: <m1tzhkzald.fsf@frodo.ebiederm.org>
References: <20080429171015.473938697@theryb.frec.bull.fr>
	<20080429173621.GA16625@suse.de>
	<20080429180445.GA18110@sergelap.austin.ibm.com>
	<20080429184151.GA19794@suse.de>
	<20080429193417.GA19282@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <gregkh@suse.de>, Benjamin Thery <benjamin.thery@bull.net>,
	linux-kernel@vger.kernel.org, Al Viro <viro@ftp.linux.org.uk>,
	Tejun Heo <htejun@gmail.com>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Pavel Emelyanov <xemul@openvz.org>, netdev@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:57660 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752655AbYD2UTb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2008 16:19:31 -0400
In-Reply-To: <20080429193417.GA19282@sergelap.austin.ibm.com> (Serge
	E. Hallyn's message of "Tue, 29 Apr 2008 14:34:17 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Serge E. Hallyn" <serue@us.ibm.com> writes:

> Ah I see it, thanks.

Serge thanks for your productive and detailed reply to this.

> The last question of Al's which went unanswered was
>
>> Excuse me, _what_?  Are you seriously suggesting going through all dentry
>> trees, doing d_move() in each?  I want to see your locking.  It's promising
>> to be worse than devfs had ever been.  Much worse.
>
> I think this is answered in patch 4.  So yeah, it does d_move() in each
> sysfs mount.  It's all done under the sysfs_rename_mutex.  Judging by
> the phrasing of the question, is that not acceptable?

We also have to call sysfs_grab_supers to ensure none of the superblocks
we know about will go away during the rename.  I believe that is the
only locking change from the current code.

Eric
