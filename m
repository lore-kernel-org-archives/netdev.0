From: Mark Smith <ipng@69706e6720323030352d30312d31340a.nosense.org>
Subject: Is it valid to add a macvlan virtual interface to a bridge? If so,
 there seems to be a bug with it.
Date: Thu, 4 Dec 2008 20:33:52 +1030
Message-ID: <20081204203352.9740c60e.ipng@69706e6720323030352d30312d31340a.nosense.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: kaber@trash.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.mail.adnap.net.au ([203.6.132.75]:62697 "EHLO
	smtp1.mail.adnap.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754710AbYLDKvg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2008 05:51:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Is it valid to add a macvlan interface to a bridge? I've been having
some trouble with inbound unicast traffic not being forwarded into or
across the bridge, yet inbound broadcast or outbound unicast traffic
being delivered across the bridge correctly.

My setup has been as follows:

o  One physical ethernet interface, purely used to "host" macvlan
interfaces i.e. no IP address, not added to the bridge.

o  Quite a number of macvlan interfaces (I've found the limit of
99 :-) ).

o  Most of those macvlan interfaces are used by individual
instances of roaring penguin pppoe-server. This has worked fine.

o  One of the macvlan interfaces is in a bridge instance, with the
other interface in the bridge being a tap interface. Attached to the
tap interface is guest virtual host, also running a pppoe server.

This bridged macvlan setup seemed to be working ok, as I was seeing
incoming broadcast traffic and outgoing unicast traffic. My full setup
wasn't working correctly, so I spent quite a bit of time investigating
other possible causes. I finally came back around to the bridged macvlan
interface, and then noticed that only incoming unicast traffic wasn't
being bridged/forwarded to the device behind the tap interface.
Bridging the tap interface with another real physical interface resolved
the issue.

I've had a look at the dev.c file in 2.6.27, and my very naive guess
is that as the handle_bridge() call is before the handle_macvlan() call,
because the incoming real physical interface is not part of the bridge,
the incoming unicast packet is being dropped, before the macvlan code
gets a look at it.

Should what I'm doing be working or possible? If not, could something
be added to the kernel to prevent macvlan interfaces being added to
bridge instances, to stop other people spending time trying to do what
I've tried to do?

Thanks,
Mark.
