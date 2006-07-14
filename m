From: Jamal Hadi Salim <hadi@cyberus.ca>
Subject: Re: [DOC]: generic netlink
Date: Fri, 14 Jul 2006 07:43:33 -0400
Message-ID: <1152877414.5125.40.camel@jzny2>
References: <1150724482.5815.48.camel@jzny2>
	 <20060713105028.b262b95e.rdunlap@xenotime.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, tgraf@suug.ch,
	jlan@engr.sgi.com, nagar@watson.ibm.com, per.liden@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:29598 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S1161090AbWGNLni
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jul 2006 07:43:38 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1G1M56-0000RJ-HY
	for netdev@vger.kernel.org; Fri, 14 Jul 2006 07:43:40 -0400
To: "Randy.Dunlap" <rdunlap@xenotime.net>
In-Reply-To: <20060713105028.b262b95e.rdunlap@xenotime.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-13-07 at 10:50 -0700, Randy.Dunlap wrote:
> On Mon, 19 Jun 2006 09:41:22 -0400 jamal wrote:
> 
> > 
> > Folks,
> > 
> > Attached is a document that should help people wishing to use generic
> > netlink interface. It is a WIP so a lot more to go if i see interest.
> 
> Hi,
> I have a few random questions about gen-netlink.
> 
> 1.  Provider IDs (numbers) and names must be unique.  Does
> this affect virtualization in any way or is it just transparent?
> 

You are referring to the openvz type of virtualization i suspect, no?
i.e not XEN or UML etc.
Good question. I think whatever those folks do for standard sockets will
work in this case as well; it is related to the way they handle process
management in the different virtual compartments. So if standard netlink
is transparent, I believe gen-netlink will be as well. A quick test is
to run "ip mon" on one VE and see if adding a route on another generates
an event on the former VE.

> 2.  Is (generic) netlink meant (expected, OK) to be used for
> non-networking ioctl/sysfs replacements?

It is OK to be used but i am not sure if we are saying it is _the_
replacement for ioctls for example. It certainly has many advantages
over ioctl/sysfs - eg (an incomplete list):
- ability to generate asynchronous events from the kernel. 
- ability to do bulk transfers from/to the kernel to/from user-space
(look at the way what Shailabh is working on may end up transmitting
upto a few MB of data from the kernel at a time)
- ability to do simple attribute set/get/event or a complex
(multi-nested) vector of such attributes
- ability to act as an IPC between user-user or user-kernel
- ability to do  one to many communication; so a single user space
message could be sent to many kernel _and user_ destinations and the
reverse a single kernel message could be sent to many kernel or user
listeners.
- the fact that it is a "a network wire" format allows for it to be used
for inter-machine communication (in a distributed system type setup for
example). 

etc

Try doing the above with ioctl or sysfs ;->

cheers,
jamal

