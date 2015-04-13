From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 1/4] ipv4: add option to drop unicast encapsulated in L2
 multicast
Date: Mon, 13 Apr 2015 12:57:16 +0200
Message-ID: <1428922636.2355.7.camel@sipsolutions.net>
References: <1428652454-1224-1-git-send-email-johannes@sipsolutions.net>
	  <alpine.LFD.2.11.1504101445330.1538@ja.home.ssi.bg>
	 <1428671435.1890.22.camel@sipsolutions.net>
	 <alpine.LFD.2.11.1504111305440.2449@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	matti.gottlieb@intel.com
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:48852 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932246AbbDMK5b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Apr 2015 06:57:31 -0400
In-Reply-To: <alpine.LFD.2.11.1504111305440.2449@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Julian,

> > Hm. I didn't see this in my testing so far, but I only enable this
> > temporarily, so perhaps by that time it was already done.
> 
> 	I didn't tested it myself, may be you can try:
> 
> other_host_on_LAN# arp -d patched_box
> other_host_on_LAN# arping -c 1 -I eth0 patched_box
> 
> 	There must be reply for broadcast requests.

Sure; I would have expected this to have broken my network but as I
said, it was only enabled temporarily.

> > On the other hand, there's not all that much reason not to put this into
> > ip_rcv_finish(), we already touch the rt->rt_type there for MIB
> > counters. I'll look into that.
> 
> 	May be in ip_local_deliver_finish because:
> 
> - ip_forward() already has PACKET_HOST check.
> 
> - for broadcast/multicast dests we do not care
> 
> - CLUSTERIP works in LOCAL_IN (after ip_rcv_finish), LOCAL_IN
> is here: ip_rcv_finish->dst_input->ip_local_deliver->
> ip_local_deliver_finish

It's just that the later this is, the more nervous I get about it being
really effective. :)

I'm willing to discount the CLUSTERIP case, it seems insane to want to
run CLUSTERIP over wifi on a network that explicitly limits multicast.

Other than that, do you see any reason for not putting it in
ip_rcv_finish()?

johannes
