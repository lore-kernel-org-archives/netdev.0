From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: broken link-local multicast?
Date: Fri, 15 Feb 2008 09:31:00 +0200 (EET)
Message-ID: <alpine.LRH.1.00.0802150928020.3621@netcore.fi>
References: <20080214162834.GA29186@bongo.bofh.it>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
To: md@linux.it, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from netcore.fi ([193.94.160.1]:54001 "EHLO netcore.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760988AbYBOHbJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Feb 2008 02:31:09 -0500
In-Reply-To: <20080214162834.GA29186@bongo.bofh.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 14 Feb 2008, Marco d'Itri wrote:
> Does anybody have any idea about how to debug this?
>
> root@frwl-5a:~# ping6 -c 1 -I eth1 ff02::1
> connect: Network is unreachable

Maybe 'netstat -gn' could give clues, because you should be receiving 
a response at least from the loopback address.  Maybe your loopback 
interface has went down, or ospf6d took it down and back up (at least 
some time ago, kernel's v6 got very confused after that).

You may also want to check out that your link-local address on the 
interface you're pinging is still OK.

# netstat -gn | grep ff02
lo              1      ff02::1
eth0            2      ff02::1:ff7b:259
eth0            1      ff02::1

# ping6 -c 1 -I eth0 ff02::1
PING ff02::1(ff02::1) from fe80::207:e9ff:fe7b:259 eth0: 56 data bytes
64 bytes from ::1: icmp_seq=0 ttl=64 time=0.057 ms

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
