From: Greg KH <gregkh@suse.de>
Subject: Re: [PATCH 10/11] avoid kobject name conflict with different
	namespaces
Date: Wed, 7 May 2008 12:08:38 -0700
Message-ID: <20080507190838.GA4467@suse.de>
References: <20080506173030.653828076@theryb.frec.bull.fr> <20080506173335.922289888@theryb.frec.bull.fr> <m13aoueyq8.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benjamin Thery <benjamin.thery@bull.net>,
	linux-kernel@vger.kernel.org, Tejun Heo <htejun@gmail.com>,
	Al Viro <viro@ftp.linux.org.uk>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	"Serge E. Hallyn" <serue@us.ibm.com>,
	Pavel Emelyanov <xemul@openvz.org>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.suse.de ([195.135.220.2]:42530 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763671AbYEGTO2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 May 2008 15:14:28 -0400
Content-Disposition: inline
In-Reply-To: <m13aoueyq8.fsf@frodo.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 07, 2008 at 11:49:19AM -0700, Eric W. Biederman wrote:
> Unless there is another path I think placing an additional pointer in
> kobj_type so we can find it through ktype is the simplest solution.
> Although using the kset is also sane.

Ick, ick, ick :)

> The easiest and most trivially correct thing to do would be to simply
> remove the unnecessary check from kobject_rename.  We perform the
> check at the upper levels in the network anyway.  And kobject_rename
> is only used by the network stack.

Wireless uses it also for some things, and it requires that it fail if a
duplicate is found.  I thought that s390 also used it, but I don't see
that usage in the tree anymore, perhaps they switched to something else.

good luck,

greg k-h
