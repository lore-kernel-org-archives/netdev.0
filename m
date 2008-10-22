From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 0/4][RFC] netns: sysfs: add a netns suffix to net device
 sysfs entries
Date: Wed, 22 Oct 2008 14:55:07 -0700
Message-ID: <20081022145507.2d1ea86c@extreme>
References: <20081022152144.351965414@theryb.frec.bull.fr>
	<m1d4hso0ym.fsf@frodo.ebiederm.org>
	<20081022203045.GA4633@us.ibm.com>
	<m18wsgmji0.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Serge E. Hallyn" <serue@us.ibm.com>,
	Benjamin Thery <benjamin.thery@bull.net>,
	netdev <netdev@vger.kernel.org>,
	Dave Miller <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Al Viro <viro@ftp.linux.org.uk>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	linux-kernel@vger.kernel.org, Tejun Heo <htejun@gmail.com>,
	Denis Lunev <den@openvz.org>,
	Linux Containers <containers@lists.linux-foundation.org>
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54781 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752806AbYJVVzL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Oct 2008 17:55:11 -0400
In-Reply-To: <m18wsgmji0.fsf@frodo.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 22 Oct 2008 14:01:59 -0700
ebiederm@xmission.com (Eric W. Biederman) wrote:

> "Serge E. Hallyn" <serue@us.ibm.com> writes:
> 
> > Quoting Eric W. Biederman (ebiederm@xmission.com):
> >> Benjamin Thery <benjamin.thery@bull.net> writes:
> >> 
> >> > Support for network namespaces in mainline is pretty complete for
> >> > some time now, but there is still this issue with sysfs that prevents 
> >> > more people to use it easily.
> >> 
> >> Ben your patchset is completely inappropriate.
> >> 
> >> Temporarily adding elements to the ABI that we intend to remove
> >> is not a proper solution to this problem.
> >> 
> >> That user space visible ida you add is a namespace identifier that breaks
> >> nested containers and migration.  It is very very very wrong.
> >
> > I disagree (not surprising :) completely.  The well-known userspace
> > tools (ifconfig, ip, etc) will not see the lo@1, they'll see lo.
> > Userspace in a container can either umount /sys completely, or do
> 
> The well-known user space tools don't use /sys at all.  Modern
> network tools use rtnetlink (ip) old network tools use /proc/net.
> 
> Very few things actually use /sys and for those things lo@1 or
> eth0@1 are completely useless except for implementing a FUSE
> mock up of sysfs.  But you don't need anything in sysfs to do
> that as all of the interesting information is available through
> /proc/net or rtnetlink.

Lots of scripts are starting use /sys for things. It is easier to
parse /sys/class/net than the output of ifconfig or ip 
