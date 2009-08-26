From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: multicast routing and multiple interfaces with same IP
Date: Thu, 27 Aug 2009 02:53:18 +0300
Message-ID: <200908270253.19132.opurdila@ixiacom.com>
References: <1b9338490908111626j55b49177q71b8a373b6e6381b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Ilia K." <mail4ilia@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:18564 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754246AbZHZXze (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 19:55:34 -0400
In-Reply-To: <1b9338490908111626j55b49177q71b8a373b6e6381b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 12 August 2009 02:26:21 Ilia K. wrote:
> Hi All,
> When routing daemon wants to enable forwarding of multicast traffic it
> performs something like:
>
> 	struct vifctl vc = {
> 		.vifc_vifi  = 1,
> 		.vifc_flags = 0,
> 		.vifc_threshold = 1,
> 		.vifc_rate_limit = 0,
> 		.vifc_lcl_addr = ip, /* <--- ip address of physical interface, e.g. eth0
> */ .vifc_rmt_addr.s_addr = htonl(INADDR_ANY),
> 	  };
> 	setsockopt(fd, IPPROTO_IP, MRT_ADD_VIF, &vc, sizeof(vc));
>
> This leads (in the kernel) to call to vif_add() function call which
> search the (physical) device using assigned IP address:
> 	dev = ip_dev_find(net, vifc->vifc_lcl_addr.s_addr);
>
> It seems like API (struct vifctl) does not allow to specify an
> interface other way than using it's IP, and if there are more than a
> single interface with specified IP only the first one will be found
> (for example it makes problems when tunnel is configured using the
> same IP as underlying interface).
>
> Am I correct in identifying the problem?
> I can propose the attached patch against 2.6.30.4.
>

Hi Ilia,

I don't have context on multicast routing, but this caught my attention:

>@@ -61,11 +61,13 @@ 
> 	unsigned int vifc_rate_limit;	/* Rate limiter values (NI) */
> 	struct in_addr vifc_lcl_addr;	/* Our address */
> 	struct in_addr vifc_rmt_addr;	/* IPIP tunnel addr */
>+	int ifindex;			/* Local interface index */
> };
>

Wouldn't this break userspace ABI? 

Perhaps you could use a union between vifc_lcl_addr and vifc_ifindex, they seem 
to be exclusive.

tavi

