From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3] vxlan: Do not reuse sockets for a different
 address family
Date: Thu, 13 Nov 2014 15:20:25 -0500 (EST)
Message-ID: <20141113.152025.1790925339761299005.davem@davemloft.net>
References: <54ab998424b7b06d892eec6df6a8ec38db3cb2bb.1415896616.git.mleitner@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	sergei.shtylyov@cogentembedded.com
To: mleitner@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59227 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933988AbaKMUU2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 15:20:28 -0500
In-Reply-To: <54ab998424b7b06d892eec6df6a8ec38db3cb2bb.1415896616.git.mleitner@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Date: Thu, 13 Nov 2014 14:43:08 -0200

> Currently, we only match against local port number in order to reuse
> socket. But if this new vxlan wants an IPv6 socket and a IPv4 one bound
> to that port, vxlan will reuse an IPv4 socket as IPv6 and a panic will
> follow. The following steps reproduce it:
> 
>    # ip link add vxlan6 type vxlan id 42 group 229.10.10.10 \
>        srcport 5000 6000 dev eth0
>    # ip link add vxlan7 type vxlan id 43 group ff0e::110 \
>        srcport 5000 6000 dev eth0
>    # ip link set vxlan6 up
>    # ip link set vxlan7 up
>    <panic>
 ...
> So address family must also match in order to reuse a socket.
> 
> Reported-by: Jean-Tsung Hsiao <jhsiao@redhat.com>
> Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>

Hey, this one actually compiles :-)

Applied and queued up for -stable, thanks!
