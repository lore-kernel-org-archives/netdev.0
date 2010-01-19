From: =?UTF-8?Q?Kolbj=C3=B8rn_Barmen?= <linux@kolla.no>
Subject: IPv6 autoconf/accept_ra default values - revisited
Date: Wed, 20 Jan 2010 00:45:37 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1001200020280.9283@firda.kolla.no>
References: <> <1237945752-14362-1-git-send-email-brian.haley@hp.com> <49C99315.6070504@hp.com> <alpine.LNX.2.00.0903250526050.6682@firda.kolla.no> <49CA4D86.4070403@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Vlad Yasevich <vladislav.yasevich@hp.com>, davem@davemloft.net,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ufisa.uninett.no ([158.38.152.126]:38936 "EHLO ufisa.uninett.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753738Ab0ATAMd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jan 2010 19:12:33 -0500
In-Reply-To: <49CA4D86.4070403@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Cheers, remember me? :)

Regarding the autoconf parameter for the ipv6 module, was it not the
intention that it should cover accept_ra as well?

I ask since I have used this paramater in the belief that it also did
cover accept_ra, however on a couple of systems that are using bridge
interface, I noticed that they "fall off" ipv6-wise, unless I explisitly
ping them.

So I finally got around to find out what was going on, and to my surprise
I see that they both have autoconfigured routes on eth0 (using link local)
that they want to use instead of what I have statically configured for br0.

So, could "autoconf" also please turn off accept_ra?
Or, if you like, add another parameter for it :P

I tried using disable_ipv6 in all kinds of tricky ways to get what I want,
but it's close to impossble, with interfaces coming and going in the
bridge I always end up with autoconfigured addresses where I dont want
them, strange routing issues etc. I cannot just add entries in sysctl.conf
for bridge interfaces, since the bridge interfaces (and others for that
matter) are not there when sysctl is run on bootup.

And the entire "all" vs. "default" still confuses me.

* "default" is supposed to cover _all future_ interfaces?
* "all" is supposed to cover _all existing_ interfaces, and change them?
  If not, then what is its function?


And lastly - all this would be a non-issue if the defaults values were so
that all autoconf/accept_ra were 0 - it's _so_ easy to turn on, but
incredibly complicated to turn off. The harder it is to make sense out of
things like this, the harder it is to have people start with IPv6.

Cheers again! :)

-- kolla
