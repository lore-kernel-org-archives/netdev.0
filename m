From: David Miller <davem@davemloft.net>
Subject: Re: iptables breakage on fc8 with recent kernels
Date: Mon, 03 Mar 2008 22:55:49 -0800 (PST)
Message-ID: <20080303.225549.191075913.davem@davemloft.net>
References: <20080303214725.92ba0955.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54675
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753796AbYCDGzw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 01:55:52 -0500
In-Reply-To: <20080303214725.92ba0955.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Mon, 3 Mar 2008 21:47:25 -0800

> I've noticed that my fc8 initscripts have been failing for a while with:
> 
> ip6tables-restore: line 20 failed
> iptables-restore: line 20 failed
> 
> It could be that this was caused by some config change which broke `make
> oldconfig', but from a quick look nothing stands out.
> 
> Here's my /etc/sysconfig/iptables:
> 
> # Firewall configuration written by system-config-firewall
> # Manual customization of this file is not recommended.
> *filter
> :INPUT ACCEPT [0:0]
> :FORWARD ACCEPT [0:0]
> :OUTPUT ACCEPT [0:0]
> :RH-Firewall-1-INPUT - [0:0]
> -A INPUT -j RH-Firewall-1-INPUT
> -A RH-Firewall-1-INPUT -i lo -j ACCEPT
> -A RH-Firewall-1-INPUT -p icmp --icmp-type any -j ACCEPT
> -A RH-Firewall-1-INPUT -p 50 -j ACCEPT
> -A RH-Firewall-1-INPUT -p 51 -j ACCEPT
> -A RH-Firewall-1-INPUT -p udp --dport 5353 -d 224.0.0.251 -j ACCEPT
> -A RH-Firewall-1-INPUT -p udp -m udp --dport 631 -j ACCEPT
> -A RH-Firewall-1-INPUT -p tcp -m tcp --dport 631 -j ACCEPT
> -A RH-Firewall-1-INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
> -A RH-Firewall-1-INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT
> -A RH-Firewall-1-INPUT -j REJECT --reject-with icmp-host-prohibited
> -A FORWARD -j REJECT --reject-with icmp-host-prohibited
> COMMIT
 ...
> So it is
> 
>    -A RH-Firewall-1-INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
> 
> which is now failing.
> 
> config: http://userweb.kernel.org/~akpm/config-t61p.txt

Please set CONFIG_NF_CONNTRACK.

Sorry about that, I think we did something stupid a few
releases ago.
