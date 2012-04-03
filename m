From: Dave Jones <davej@redhat.com>
Subject: Re: NULL pointer dereference at __ip_route_output_key
Date: Mon, 2 Apr 2012 20:22:00 -0400
Message-ID: <20120403002200.GA21262@redhat.com>
References: <20120402194056.GA1002@redhat.com>
 <20120402.200711.2234324385609269937.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-team@fedoraproject.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15606 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750962Ab2DCAWE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Apr 2012 20:22:04 -0400
Content-Disposition: inline
In-Reply-To: <20120402.200711.2234324385609269937.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 02, 2012 at 08:07:11PM -0400, David Miller wrote:

 > > We just had this reported. Look familiar to anyone ?
 > 
 > If you could unravel the source file and line the OOPS occurs at, I
 > can look at these kinds of reports much faster.  As it stands, when I
 > see a Fedora OOPS, it's a long process for me:

Ok, I'll try and pull these apart for you in future, as I usually
have the bits for the most recent builds around. 

 > Anyways in this case dev_out is NULL when we read it around line
 > 2798 of net/ipv4/route.c:
 > 
 > 	dev_out = FIB_RES_DEV(res);
 > 	fl4->flowi4_oif = dev_out->ifindex;
 > 
 > and we are thus OOPS'ing on the dev_out->ifindex.
 > 
 > Unfortunately I've never seen a report like this.  If the reporter can
 > reproduce, you can try to extract more information by doing something
 > like this right after the dev_out assignment:
 > 
 > 	if (!dev_out) {
 > 		pr_crit("ipv4: FIB_RES_DEV() is NULL, nh_sel=%d\n",
 > 			res.nh_sel);
 > 		rth = ERR_PTR(-EINVAL);
 > 		goto out;
 > 	}
 > 
 > This debugging will also avoid the NULL pointer crash at least for
 > that particular invocation.

ok, I'll do a test build with this change for the user to try out.
Hopefully he can retrigger it.

thanks,

	Dave
