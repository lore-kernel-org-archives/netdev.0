From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 7398] New: Preferred source address selection
 ("src" field) broken with multicast addresses
Date: Sun, 22 Oct 2006 14:00:58 -0700 (PDT)
Message-ID: <20061022.140058.92582309.davem@davemloft.net>
References: <20061022114020.3b5a6042.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	linkfanel@yahoo.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:30623
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750872AbWJVVA6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Oct 2006 17:00:58 -0400
To: akpm@osdl.org
In-Reply-To: <20061022114020.3b5a6042.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@osdl.org>
Date: Sun, 22 Oct 2006 11:40:20 -0700

>         if (oldflp->oif == 0
>             && (MULTICAST(oldflp->fl4_dst) || oldflp->fl4_dst == 0xFFFFFFFF)) {
>             /* Special hack: user can direct multicasts
>                and limited broadcast via necessary interface
>                without fiddling with IP_MULTICAST_IF or IP_PKTINFO.
>                This hack is not just for fun, it allows
>                vic,vat and friends to work.
>                They bind socket to loopback, set ttl to zero
>                and expect that it will work.
>                From the viewpoint of routing cache they are broken,
>                because we are not allowed to build multicast path
>                with loopback source addr (look, routing cache
>                cannot know, that ttl is zero, so that packet
>                will not leave this host and route is valid).
>                Luckily, this hack is good workaround.
>              */
> 
>             fl.oif = dev_out->ifindex;
>             goto make_route;
>         }

This code and behavior has been there for 11 years.  It is very
unlikely we can change this behavior and not break the kinds of
applications being mentioned in the comment.

Please close this.
