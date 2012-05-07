From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Netlink for kernel<->user space communication?
Date: Mon, 7 May 2012 15:33:07 -0700
Message-ID: <20120507153307.551b29ed@nehalam.linuxnetplumber.net>
References: <4FA817C8.9040204@xdin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Arvid Brodin <Arvid.Brodin@xdin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52583 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753340Ab2EGWdL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 May 2012 18:33:11 -0400
In-Reply-To: <4FA817C8.9040204@xdin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 7 May 2012 18:43:23 +0000
Arvid Brodin <Arvid.Brodin@xdin.com> wrote:

> On Tue, 24 Apr 2012 16:57:55 -0700
> Stephen Hemminger <shemminger@xxxxxxxxxx> wrote:
> > On Tue, 24 Apr 2012 23:52:34 +0000
> > Arvid Brodin <Arvid.Brodin@xxxxxxxx> wrote:
> > 
> >> Hi.
> >> 
> >> I'm writing a kernel driver for the HSR protocol, a standard for high availability
> >> networks. I want to send messages from the kernel to user space about broken network
> >> links. I also want user space to be able to ask the kernel about its view of the status of
> >> nodes on the network.
> >> 
> >> Netlink seems like a good tool for this. (Is it?)
> > 
> > Yes.
> > 
> >> But do I use raw netlink? (Described here: http://www.linuxjournal.com/article/7356 - but
> >> this seems a bit out of date, the kernel API description differs from today's kernel
> >> implementation.)
> > 
> > No. Your driver probably looks like a device so you should be
> > using rtnetlink messages.
> 
> I'm already using rtnetlink messages to add and remove my device, which works fine (see
> e.g. http://www.spinics.net/lists/netdev/msg192817.html - although I didn't think it
> meaningful to include the iproute2 patch here, until the kernel part is ready).
> 
> The protocol specifies transmission of "supervision frames" every 2 seconds, e.g. to check
> link integrity. Every such frame should be received from two directions in the ring - if
> only one is received, then there is a link problem.

Why not just manipulate the carrier or operational state (see Documentation/networking/operstate)
and use the existing notification on link changes. If you don't get heartbeat then change
the state of the device to indicate lower device is down with set_operstate(), the necessary
link everts propgate back as netlink events.

> I'd like to notify user space about every such occurence. Is there a rtnetlink message
> type that fits this? The stuff in rtnetlink.h seems to be mostly concerned with specific
> user space commands (there is something called RTNLGRP_NOTIFY but I couldn't find any
> instances of it being used in the kernel, nor any documentation).
> 

I am trying to steer you to use existing API's because then existing programs and
infrastructure can deal with the new device type.
