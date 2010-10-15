From: Jesse Gross <jesse@nicira.com>
Subject: Re: openvswitch/flow WAS ( Re: [rfc] Merging the Open vSwitch datapath
Date: Fri, 15 Oct 2010 14:35:53 -0700
Message-ID: <AANLkTim2LsFUOVSVss6HqGTxuyGH6eBKQdYabjMoWiaB@mail.gmail.com>
References: <20100830062755.GA22396@verge.net.au>
	<87k4n8ow1r.fsf@benpfaff.org>
	<1287142292.3642.19.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Ben Pfaff <blp@nicira.com>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:53117 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751203Ab0JOVf4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Oct 2010 17:35:56 -0400
Received: by iwn35 with SMTP id 35so1317952iwn.19
        for <netdev@vger.kernel.org>; Fri, 15 Oct 2010 14:35:55 -0700 (PDT)
In-Reply-To: <1287142292.3642.19.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 15, 2010 at 4:31 AM, jamal <hadi@cyberus.ca> wrote:
> It seems to me that you reinvented things that exist in
> Linux already such as bridging, tunnels and what really
> caught my attention: ability to do flows (tc actions).
> It is possible Linux is missing something you wanted or was
> not efficient enough?
> [For example: I couldnt see anything you needed
> on flow-action management that Linux couldnt do already
> (with already very nice well structured netlink APIs)]

You're right, at a high level, it appears that there is a bit of an
overlap between bridging, tc, and Open vSwitch.  However, in reality
each is targeting a pretty different use case.  Given that the design
goals are not aligned, keeping separate things separate actually helps
with overall simplicity.  Where there is overlap, I am certainly happy
to see common functionality reused: for example, Open vSwitch uses tc
for its QoS capabilities.

In the future, I expect there to be an even clearer delineation
between the various components.  One of the primary use cases of Open
vSwitch at the moment is for virtualized data center networking but a
few of the other potential uses that have been brought up include
security processing (involving sending traffic of interest to
userspace) and configuring SR-IOV NICs (to appropriately program rules
in hardware).  You can see how each of these makes sense in the
context of a virtual switch datapath but less so as a set of tc
actions.

So, in short, I don't see this as something lacking in Linux, just
complementary functionality.
