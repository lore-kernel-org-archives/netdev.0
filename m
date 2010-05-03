From: Dan Smith <danms@us.ibm.com>
Subject: Re: [PATCH] [RFC] C/R: inet4 and inet6 unicast routes (v2)
Date: Mon, 03 May 2010 07:21:02 -0700
Message-ID: <87y6g1xe0h.fsf@caffeine.danplanet.com>
References: <1272646855-17327-1-git-send-email-danms@us.ibm.com>
	<4BDB3F07.2030900@free.fr> <87bpd0zl9l.fsf@caffeine.danplanet.com>
	<1272673614.14499.10.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Lezcano <daniel.lezcano@free.fr>, containers@lists.osdl.org,
	Vlad Yasevich <vladislav.yasevich@hp.com>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw0.danplanet.com ([71.245.107.82]:38157 "EHLO
	mail.danplanet.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932421Ab0ECOVR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 10:21:17 -0400
In-Reply-To: <1272673614.14499.10.camel@bigi> (jamal's message of "Fri\, 30 Apr 2010 20\:26\:54 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

j> The problem as i see it (with all net structures not just routes -
j> i was equally pessimistic when i saw those other net structure
j> checkpoint/restore changes) is you are faced with a herculean
j> high-maintainance effort...  You have a separate piece of code
j> which populates structures that _you_ maintain for attributes that
j> are defined elsewhere by other people.  Nobody adding a new
j> attribute that is very important to route restoration for example
j> is likely to change your code. Unless you tie the two together (so
j> changing one forces the coder to change the other).  And once
j> people deploy kernels it is hard to change. Historically (for
j> pragmatic reasons) such rich interfaces sit in user space - much
j> easier to update user space.

The benefits of doing what we can in userspace are well-understood and
arguing for doing so where it makes sense is, of course, a good idea.

However, it seems to me that the rtnl interface provides us a
reasonable layer of isolation between us and such changes.  Am I
wrong?  The rtnl messages appear to be rather generic and timeless,
and in most cases have a significant amount of flexibility with
respect to allowing advanced attributes to be ignored (which implies
taking the default).

In many other areas of C/R we're not so lucky and don't have a
well-defined interface for dumping that information out of the
kernel...

-- 
Dan Smith
IBM Linux Technology Center
email: danms@us.ibm.com
