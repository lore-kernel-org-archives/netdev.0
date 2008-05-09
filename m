From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 10/11] avoid kobject name conflict with different namespaces
Date: Fri, 09 May 2008 11:16:10 -0700
Message-ID: <m1ve1nbaxh.fsf@frodo.ebiederm.org>
References: <20080506173030.653828076@theryb.frec.bull.fr>
	<20080506173335.922289888@theryb.frec.bull.fr>
	<m13aoueyq8.fsf@frodo.ebiederm.org> <20080507190838.GA4467@suse.de>
	<m1hcd9esxo.fsf@frodo.ebiederm.org>
	<20080508102844.25642ef7@gondolin.boeblingen.de.ibm.com>
	<m1myn0d298.fsf@frodo.ebiederm.org>
	<20080509073556.3c342d14@gondolin.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ebiederm@xmission.com (Eric W. Biederman),
	Greg KH <gregkh@suse.de>,
	Benjamin Thery <benjamin.thery@bull.net>,
	linux-kernel@vger.kernel.org, Tejun Heo <htejun@gmail.com>,
	Al Viro <viro@ftp.linux.org.uk>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	"Serge E. Hallyn" <serue@us.ibm.com>,
	Pavel Emelyanov <xemul@openvz.org>, netdev@vger.kernel.org
To: Cornelia Huck <cornelia.huck@de.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761640AbYEISUw@vger.kernel.org>
In-Reply-To: <20080509073556.3c342d14@gondolin.boeblingen.de.ibm.com>
	(Cornelia Huck's message of "Fri, 9 May 2008 07:35:56 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cornelia Huck <cornelia.huck@de.ibm.com> writes:

> On Thu, 08 May 2008 12:28:19 -0700,
> ebiederm@xmission.com (Eric W. Biederman) wrote:
>
>> Do you remember if we have ever sorted out the race between _move
>> and module unload/directory teardown at the sysfs level?
>
> Unfortunately I can't remember anything about this, do you have a
> pointer to the original discussion?

Ok the conversation was:
"[Bluez-devel] Oops involving RFCOMM and sysfs"
http://lkml.org/lkml/2007/12/28/87

Following the thread through it appears the bug was fixed
and it wasn't the race Al Viro was concerned about.
http://lkml.org/lkml/2008/1/9/59

And it looks like all of the symptoms have been corrected.
Yeah!

Which implies to me that kobject_move has the same locking
restrictions that kobject_rename has.  I.e. the upper level
better do what it takes to make the operation safe.

Which says that at least for now not worrying about the locking
between sysfs_move_dir/sysfs_rename_dir and sysfs_remove_dir is ok.
As we require the upper levels not to do that.

Which says that we may be able to figure out how to merge
sysfs_move_dir and sysfs_rename_dir.  It is still a nasty business
though.

Eric
