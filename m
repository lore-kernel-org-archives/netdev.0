From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: Issue with LACP mode in linux bonding driver
Date: Thu, 25 Jun 2015 19:15:02 -0700
Message-ID: <6462.1435284902@famine>
References: <CADAe=+LvNgHV+crN_+E4xB+Pcz=KSvZpK5ADKzYFjHL2gGJq2Q@mail.gmail.com>
Cc: vfalico@gmail.com, gospo@cumulusnetworks.com,
	netdev@vger.kernel.org
To: Ajith Adapa <adapa.ajith@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:47639 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752372AbbFZCPI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2015 22:15:08 -0400
In-reply-to: <CADAe=+LvNgHV+crN_+E4xB+Pcz=KSvZpK5ADKzYFjHL2gGJq2Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ajith Adapa <adapa.ajith@gmail.com> wrote:

>Hi,
>
>Sorry for direct mail. Since the question is more specific about
>supporting LACP standard I decided to communicate directly with the
>MAINTAINERS. My issue is related to multiaggregation support in LACP.

	I saw your message this morning, but didn't have an opportunity
to look into it today.

>Linux Flavour: Centos7.
>Setup topology: Back to back connected Linux server and a L2 switch
>with 2 interfaces eth0 and eth1 (on both sides).
>
>On Switch I have mapped eth0 to po1 and eth1 to po2. On Linux server I
>have created a single bond interface with both interfaces eth0 and
>eth1.
>
>On switch both po1 and po2 has same system-id but the Actor key is
>different i.e. on PO1 it is 16385 and on PO2 it is 32768. As per the
>information available regarding bond0 on Linux server which is given below
>Active aggregator ID is 1 which is mapped to eth0.
>
>But we have observed that eth1 on Linux server is also sending LACPDUS
>with Collecting/Distributing bit set as 1. Which will result in single
>bond interface on Linux server is splitted into multiple port-channels
>on Switch causing duplication of frames on Linux server.

	I'd suggest enabling the dynamic_debug for the bonding driver
and observe the state machine activity within the 802.3ad code.  This is
described in the Documentation/dynamic-debug-howto.txt that is part of
the kernel source; off the top of my head, I think you'll need something
like:

echo 'module bonding =p' > /sys/kernel/debug/dynamic_debug/control

	This should put the bonding LACP state machine activity into the
system log.

	If a port on a non-active aggregator is actually in collecting /
distributing state, that is probably bad, as I'd only expect that to be
true for ports in the active aggregator.

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
