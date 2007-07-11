From: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Subject: Re: [PATCH v2 -mm 8/9] netconsole: Support multiple logging targets
Date: Wed, 11 Jul 2007 11:54:17 +0530 (IST)
Message-ID: <Pine.LNX.4.64.0707111136280.10373@cselinux1.cse.iitk.ac.in>
References: <20070710091920.23907.96483.sendpatchset@cselinux1.cse.iitk.ac.in>
 <20070710092001.23907.39876.sendpatchset@cselinux1.cse.iitk.ac.in>
 <e9e943910707100323o35cb0316i5d3f21584ad8e4ae@mail.gmail.com>
 <Pine.LNX.4.64.0707110340370.2445@cselinux1.cse.iitk.ac.in>
 <20070711042948.GS1011@tasint.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Duane Griffin <duaneg@dghda.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Matt Mackall <mpm@selenic.com>,
	Keiichi Kii <k-keiichi@bx.jp.nec.com>,
	Netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Joel Becker <Joel.Becker@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.iitk.ac.in ([203.197.196.4]:51612 "EHLO mail4.iitk.ac.in"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754439AbXGKGeK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jul 2007 02:34:10 -0400
In-Reply-To: <20070711042948.GS1011@tasint.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Joel,

On Tue, 10 Jul 2007, Joel Becker wrote:
> On Wed, Jul 11, 2007 at 03:47:09AM +0530, Satyam Sharma wrote:
> > Hmm, I put it in there because I expected that the user must have had
> > at least one target configured (added to target_list) if he's got the
> > module loaded/built-in (and netconsole registered), which is when this
> > function would be triggered anyway.
> 
> 	Loading the module won't happen without a config,

That's no longer the case (doesn't need to be enforced actually) now
with being able to add logging targets _after_ the module has loaded
and initialized / registered itself. It's plausible a user may simply
want to load netconsole without any "netconsole=" option, and then
specify/add targets later -- this wasn't possible previously, of course.

> but there's no
> requirement that a built-in netconsole has a kernel command-line
> argument.

The above is applicable for the built-in case too, with
CONFIG_NETCONSOLE_DYNAMIC. So now built-in netconsole will initialize
(configfs subsystem, etc) and register itself (register_console) even
if no "netconsole=" was provided, again for the same reason.

And I now notice that CONFIG_NETCONSOLE=y in the defconfig's of
most arch's. So I think I did get the common case wrong there ...
ok, I'll get rid of the unlikely() in that case.

Satyam
