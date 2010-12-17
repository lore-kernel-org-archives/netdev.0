From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: Re: [PATCH] iproute2: initialize the ll_map only once
Date: Fri, 17 Dec 2010 15:06:41 +0200
Message-ID: <201012171506.41834.nuclearcat@nuclearcat.com>
References: <1291993190-8838-1-git-send-email-opurdila@ixiacom.com> <20101210113809.56ea259e@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Octavian Purdila <opurdila@ixiacom.com>, netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>,
	Vlad Dogaru <ddvlad@rosedu.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:33374 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753220Ab0LQNG2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Dec 2010 08:06:28 -0500
In-Reply-To: <20101210113809.56ea259e@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 10 December 2010 21:38:09 Stephen Hemminger wrote:
> On Fri, 10 Dec 2010 16:59:50 +0200
> 
> Octavian Purdila <opurdila@ixiacom.com> wrote:
> > Avoid initializing the LL map (which involves a costly RTNL dump)
> > multiple times. This can happen when running in batch mode.
> > 
> > Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
> 
> applied
There is some longstanding bug related to current hashing system.
To "workaround" it i did my own "flush" command, to flush hashes, but with 
this patch it becomes more difficult to handle this situation.
Here is how to reproduce it:

ip -force -batch -
link add link eth0 name new0 type macvlan
link show dev new0
link delete dev new0 type macvlan
link add link eth0 name new0 type macvlan
link show dev new0

Last command will not show link, because index of old one is stored in hash.

I guess it is more bugreport for old problem, than problem with current patch.
Sure it is possible to flush hash on del/add operations, but additionally 
during batch run it is possible that interfaces can appear/disappear (NAS with 
thousands of ppp interfaces). Maybe still as an idea i can do patch with flag 
to dump rtnl before each command and additional "flush hash" command?

