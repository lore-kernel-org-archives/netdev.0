From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: [Bugme-new] [Bug 10600] New: e1000 updates rx_bytes infrequently
Date: Tue, 6 May 2008 10:22:17 -0700
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F52051AAF84@orsmsx418.amr.corp.intel.com>
References: <bug-10600-10286@http.bugzilla.kernel.org/> <20080505155502.3fb16590.akpm@linux-foundation.org> <20080505.161806.267621711.davem@davemloft.net> <481F9E64.6070606@acm.org> <1210036624.7941.183.camel@dell> <481FB33F.3040804@acm.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David Miller" <davem@davemloft.net>, <akpm@linux-foundation.org>,
	"netdev" <netdev@vger.kernel.org>,
	<bugme-daemon@bugzilla.kernel.org>,
	"Ronciak, John" <john.ronciak@intel.com>
To: "Ben Liblit" <liblit@acm.org>, "Michael Chan" <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:47087 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754207AbYEFRWT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2008 13:22:19 -0400
Content-class: urn:content-classes:message
In-Reply-To: <481FB33F.3040804@acm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Liblit wrote:
> Michael Chan wrote:
>> "ethtool -C eth0 stats-block-usecs" can be used to control statistics
>> update frequency on most tg3 and bnx2 devices.
> 
> But not on my e1000-driven Intel 82566DC, sadly:
> 
> 	# ethtool -C eth0 stats-block-usecs 50
> 	Cannot get device coalesce settings: Operation not supported
> 
> 	# ethtool -c eth0
> 	Coalesce parameters for eth0:
> 	Cannot get device coalesce settings: Operation not supported

e1000/e1000e already has patches upstream that count bytes and packets
"on the fly" to fix this sort of issue.

see commit:
commit ef90e4eca9fcade05dd03f853df75cf459a75422
Author: Auke Kok <auke-jan.h.kok@intel.com>
Date:   Tue Nov 13 20:49:15 2007 -0800

    [E1000]: update netstats traffic counters realtime

    formerly e1000/e1000e only updated traffic counters once every
    2 seconds with the register values of bytes/packets. With newer
    code however in the interrupt and polling code we can real-time
    fill in these values in the netstats struct for users to see.

    Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

and for e1000e (which you should be using for 82566)
commit 419886927796dfeca87c1fd11d1fe2ed442103cc
Author: Auke Kok <auke-jan.h.kok@intel.com>
Date:   Tue Nov 13 20:48:36 2007 -0800

    [E1000E]: update netstats traffic counters realtime

    formerly e1000/e1000e only updated traffic counters once every
    2 seconds with the register values of bytes/packets. With newer
    code however in the interrupt and polling code we can real-time
    fill in these values in the netstats struct for users to see.

    Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

I'm not sure if this patch is in 2.6.24 and my git foo is lacking... 
is this patch not working for you?  if so we need to figure out why.

Jesse
