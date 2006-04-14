From: Andrew Morton <akpm@osdl.org>
Subject: Fw: Openswan, iptables (fiaif) and 2.6.16 kernel
Date: Fri, 14 Apr 2006 10:59:17 -0700
Message-ID: <20060414105917.0db022d9.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Laurent CARON <lcaron@apartia.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:20161 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751347AbWDNSAF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2006 14:00:05 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Fri, 14 Apr 2006 14:32:39 +0200
From: Laurent CARON <lcaron@apartia.fr>
To: linux-kernel@vger.kernel.org
Subject: Openswan, iptables (fiaif) and 2.6.16 kernel


Hi,

I'm running an openswan gateway for quite a long time now.

I have used 2.4.X and 2.6.X kernels without any problem until i decided 
to upgrade to 2.6.16 kernel.

Summary of problem:

Under 2.6.15 everything is fine

Under 2.6.16 my tunnels establish well, but i can't even ping a single 
computer located on the other end of the tunnel when the firewall is up.
Disabling the firewall solves the problem (but is not an option for me).

$ cat ip_conntrack | grep 192.168.10
icmp     1 8 src=192.168.0.192 dst=192.168.10.1 type=8 code=0 id=793 
packets=4 bytes=116 [UNREPLIED] src=192.168.10.1 dst=XXX.XXX.XXX.XXX 
type=0 code=0 id=793 packets=0 bytes=0 mark=0 use=1

192.168.0.0/24 is my lan subnet (natted so that lan computers can access 
the internet through the public ip address)
192.168.0.192 is a workstation on my lan
192.168.10.0/24 is the other subnet
XXX.XXX.XXX.XXX is my public ip address


If i disable the nat of 192.168.0.0/24, i can ping the other end.

Re-enabling the nat however disables the ability to ping the other end.

Seems iptables is trying to nat packets the wrong way :$, or that I 
missed a major change in 2.6.16.

Do anyone have any clue about this weiredness?

Thanks

Laurent
_______________________________________________
Users@openswan.org
http://lists.openswan.org/mailman/listinfo/users
Building and Integrating Virtual Private Networks with Openswan: 
http://www.amazon.com/gp/product/1904811256/104-3099591-2946327?n=283155

-
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/
