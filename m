From: Willy Tarreau <w@1wt.eu>
Subject: Re: tcp_tw_recycle broken?
Date: Sat, 15 Nov 2008 06:57:48 +0100
Message-ID: <20081115055748.GY24654@1wt.eu>
References: <f9be06770811142037v794cf4f8w7a82ab45c0f3820c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Karl Pickett <karl.pickett@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1204 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751889AbYKOF5x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Nov 2008 00:57:53 -0500
Content-Disposition: inline
In-Reply-To: <f9be06770811142037v794cf4f8w7a82ab45c0f3820c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 14, 2008 at 11:37:06PM -0500, Karl Pickett wrote:
> Hey.  Developing a http proxy on fedora 9 (2.6.25) and running into a
> strange issue.
> 
> Having the proxy set up and tear down 6000 tcp connections a second to
> the same test server ip and port,
> it quickly blows up (5 seconds) due to all 30000 ephemeral ports going
> to TIME_WAIT.
> setting tw_recycle=1 fixed the problem, and there are never more than
> a couple hundred ports in TIME_WAIT.
> 
> BUT...
> 
> Changing the load test to alternate between two test server ips, it
> blows up.  Connect: can't assign requested address. (note I am not
> binding before hand, I tried
> and binding first to port 0 made no difference - it just blows up then
> during the bind).
> 
> And there are ~28K ports in TIME_WAIT.  For example:
> 
> proxy_ip:30000 load_test_1:8080 TIME_WAIT
> proxy_ip:30000 load_test_2:8080 TIME_WAIT
> ...
> but most are not duplicates of the same local port.
> 
> 
> What. The.  Heck.
> 
> So short of rebuilding the kernel with time_wait as 1 second, is there
> any other way not to brick my proxy?

two things :
  - set tcp_tw_reuse to 1 too.
  - do a setsockopt(SO_REUSEADDR) before connect()

Using this, my proxy has no problem at 35K sess/s on 2.6.25. I'm not sure
if disabling either option above still works.

Hoping this helps,
Willy

