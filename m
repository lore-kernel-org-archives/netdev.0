From: Dan Williams <dcbw@redhat.com>
Subject: Re: Q: netdev: generate kobject uevent on network events.
Date: Wed, 09 Dec 2009 11:21:26 -0800
Message-ID: <1260386486.28042.6.camel@localhost.localdomain>
References: <20091209170251.GA11650@sig21.net>
	 <ac3eb2510912091046g4e5173b1sb97d6a4dddfd0b81@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Johannes Stezenbach <js@sig21.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, linux-hotplug@vger.kernel.org
To: Kay Sievers <kay.sievers@vrfy.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15450 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750955AbZLITVj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Dec 2009 14:21:39 -0500
In-Reply-To: <ac3eb2510912091046g4e5173b1sb97d6a4dddfd0b81@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-12-09 at 19:46 +0100, Kay Sievers wrote:
> On Wed, Dec 9, 2009 at 18:02, Johannes Stezenbach <js@sig21.net> wrote:
> > about a year ago you posted a patch which allows to manage
> > network hotplug via udev (or busybox mdev), which is useful
> > for low-end embedded platforms that don't want to run ifplugd.
> >
> > http://article.gmane.org/gmane.linux.hotplug.devel/13386
> >
> > The patch still works with 2.6.32.  Can it get merged or
> > were there any issues with it?  It seems the discussion
> > just stopped and the patch was forgotten...
> 
> Can't, in some setups, these events happen at a rather high frequency?
> I heard of people running many hundreds of ppp interfaces on a single
> box acting as a DSL concentrator. They state to already have trouble
> handling the amount of uevents generated on such boxes just for the
> "add/remove" events of all the interfaces if something goes wrong with
> the network. If we add more for state transitions, such events would
> probably need to be rate-limited. In general, uevents/udev are not
> really suitable for high-frequency events, and if such behavior can be
> expected, we might better stick with the current netlink interface.

And then lets direct energy towards making the netlink interface simpler
for app writers.  Either by fixing up libnl to be dead-simple to use, or
some other mechanism.  Let's fix the *actual* problem (netlink is hard
to use from shell scripts) instead of creating more interfaces that work
around it.  Or maybe shellscripts are simply the wrong tool for this
job?

Dan


