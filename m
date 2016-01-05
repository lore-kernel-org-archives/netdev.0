From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: Propagate lookup failure in l3mdev_get_saddr
 to caller
Date: Mon, 04 Jan 2016 22:58:54 -0500 (EST)
Message-ID: <20160104.225854.1644508041816573984.davem@davemloft.net>
References: <1451927367-14527-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51399 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753884AbcAED64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 22:58:56 -0500
In-Reply-To: <1451927367-14527-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Mon,  4 Jan 2016 09:09:27 -0800

> Commands run in a vrf context are not failing as expected on a route lookup:
>     root@kenny:~# ip ro ls table vrf-red
>     unreachable default
> 
>     root@kenny:~# ping -I vrf-red -c1 -w1 10.100.1.254
>     ping: Warning: source address might be selected on device other than vrf-red.
>     PING 10.100.1.254 (10.100.1.254) from 0.0.0.0 vrf-red: 56(84) bytes of data.
> 
>     --- 10.100.1.254 ping statistics ---
>     2 packets transmitted, 0 received, 100% packet loss, time 999ms
> 
> Since the vrf table does not have a route for 10.100.1.254 the ping
> should have failed. The saddr lookup causes a full VRF table lookup.
> Propogating a lookup failure to the user allows the command to fail as
> expected:
> 
>     root@kenny:~# ping -I vrf-red -c1 -w1 10.100.1.254
>     connect: No route to host
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied, thanks David.
