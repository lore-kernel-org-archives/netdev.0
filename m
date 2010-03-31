From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/6] sysfs: Implement sysfs tagged directory support.
Date: Wed, 31 Mar 2010 15:49:39 +0900
Message-ID: <4BB2F083.1050803@kernel.org>
References: <m1fx3hk6gw.fsf@fess.ebiederm.org> <1269973889-25260-3-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh@suse.de>,
	Kay Sievers <kay.sievers@vrfy.org>,
	linux-kernel@vger.kernel.org,
	Cornelia Huck <cornelia.huck@de.ibm.com>,
	linux-fsdevel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Benjamin LaHaise <bcrl@lhnet.ca>,
	Serge Hallyn <serue@us.ibm.com>, netdev@vger.kernel.org,
	Benjamin Thery <benjamin.thery@bull.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1269973889-25260-3-git-send-email-ebiederm@xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, Eric.

On 03/31/2010 03:31 AM, Eric W. Biederman wrote:
> What this patch does is to add an additional tag field to the
> sysfs dirent structure.  For directories that should show different
> contents depending on the context such as /sys/class/net/, and
> /sys/devices/virtual/net/ this tag field is used to specify the
> context in which those directories should be visible.  Effectively
> this is the same as creating multiple distinct directories with
> the same name but internally to sysfs the result is nicer.

This has become a long running project. :-)

The way to implement partial visibility seems much cleaner now and I
don't have any objection.  Thanks for cleaning up the whole sysfs and
implementing this properly.  Unfortunately, I still feel quite
uncomfortable about how the scope of visibility is determined and how
deep knowledge about specific namespace implementation seeps down to
kobject / sysfs layer.  It almost looks like a gross layering
violation.

Is it at all possible to implement it in properly layered manner?
ie. sysfs providing mechanisms for selective visibility, driver model
wraps it and exports it and namespace implements namespaces on top of
those mechanisms?  I can see that there should be some interaction
between the driver model and namespaces but I can't see why that
information should be visible deep down in kobject and sysfs.

Thanks.

-- 
tejun
