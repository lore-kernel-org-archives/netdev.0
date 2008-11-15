From: "Karl Pickett" <karl.pickett@gmail.com>
Subject: tcp_tw_recycle broken?
Date: Fri, 14 Nov 2008 23:37:06 -0500
Message-ID: <f9be06770811142037v794cf4f8w7a82ab45c0f3820c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.233]:32093 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751782AbYKOEhH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2008 23:37:07 -0500
Received: by rv-out-0506.google.com with SMTP id k40so1673280rvb.1
        for <netdev@vger.kernel.org>; Fri, 14 Nov 2008 20:37:06 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey.  Developing a http proxy on fedora 9 (2.6.25) and running into a
strange issue.

Having the proxy set up and tear down 6000 tcp connections a second to
the same test server ip and port,
it quickly blows up (5 seconds) due to all 30000 ephemeral ports going
to TIME_WAIT.
setting tw_recycle=1 fixed the problem, and there are never more than
a couple hundred ports in TIME_WAIT.

BUT...

Changing the load test to alternate between two test server ips, it
blows up.  Connect: can't assign requested address. (note I am not
binding before hand, I tried
and binding first to port 0 made no difference - it just blows up then
during the bind).

And there are ~28K ports in TIME_WAIT.  For example:

proxy_ip:30000 load_test_1:8080 TIME_WAIT
proxy_ip:30000 load_test_2:8080 TIME_WAIT
...
but most are not duplicates of the same local port.


What. The.  Heck.

So short of rebuilding the kernel with time_wait as 1 second, is there
any other way not to brick my proxy?

--
Karl Pickett

--
Karl Pickett
