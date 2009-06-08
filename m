From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/3] sit: handle ICMPv4 for tunnels with no remote
Date: Mon, 08 Jun 2009 18:46:10 +0200
Message-ID: <4A2D4052.2010108@trash.net>
References: <1244296972-20748-1-git-send-email-contact@saschahlusiak.de> <1244296972-20748-2-git-send-email-contact@saschahlusiak.de> <20090608.024024.236334849.davem@davemloft.net> <20090608161352.152078nqk5d89e8s@www.domaingo-webmail.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, contact@saschahlusiak.de,
	netdev@vger.kernel.org
To: mail@saschahlusiak.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39714 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753180AbZFHQqK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2009 12:46:10 -0400
In-Reply-To: <20090608161352.152078nqk5d89e8s@www.domaingo-webmail.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

mail@saschahlusiak.de wrote:
> If iph.ttl == 0, it means that the ttl of the ipv4 package is inherited
> from the ipv6 package to be sent. In case the ipv4 ttl of the path
> expires, the ipv6 ttl would expire too. While the link does send a
> time_exceeded, I believe that the application should receive an ICMPv6
> time_exceeded as well, even if the package died right on the tunnel
> endpoint.

I have some patches that I wanted to post tommorrow, which will allow
to propagate errno values and queue congestion state of the underlying
device upwards from the hard_start_xmit() functions of virtual network
devices. With these patches, you can simply return -EHOSTUNREACH or
whatever is appropriate and it will be delivered to the application.

Would that help?

