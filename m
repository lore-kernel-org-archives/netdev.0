From: "Denis V. Lunev" <den@openvz.org>
Subject: RE: cgroup: limit network bandwidth
Date: Fri, 08 Feb 2008 10:52:56 +0300
Message-ID: <1202457176.31674.12.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Balbir Singh <balbir@linux.vnet.ibm.com>,
	Naveen Gupta <ngupta@google.com>,
	Paul Menage <menage@google.com>,
	Linux Containers <containers@lists.osdl.org>
To: righiandr@users.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:47190 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755127AbYBHIAE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Feb 2008 03:00:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, Andrea!

I have occasionally seen your patch on LWN (missed one in netdev@) and
have two words about. May be this is not too late. I have missed my
entire mailbox yesterday and have not followed the discussion. Pls
forgive me.

Rate-limiting message receive is nothing good at all. First, if we talk
about i386, the most important resource is low memory. There are no more
than 1 Gb of it. You suggest to keep it used more time than usual and
this usage will not reduce network traffic to the node for UDP cases.

For TCP the situation is slightly better. But not quite a big. For a
case of rather slow group with a bug traffic you will just eat 64kb *
Nsockets of receive buffers.

So, resource usage is just increased for a case. This is unfortunate. In
order to proper rate-limiting you need to calculate memory used
- dropping incoming packets early for UDP
- manage TCP window on the base of buffer memory used by the cgroup

Regards,
	Den

