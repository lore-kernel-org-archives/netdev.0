From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: tun: add tun_flags, owner, group attributes in sysfs
Date: Mon, 04 May 2009 15:58:05 +0100
Message-ID: <1241449085.6126.117.camel@macbook.infradead.org>
References: <1241433136.6126.70.camel@macbook.infradead.org>
	 <20090504074753.6d1c5bcd@nehalam>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Mark McLoughlin <markmc@redhat.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:38785 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754269AbZEDO6I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2009 10:58:08 -0400
In-Reply-To: <20090504074753.6d1c5bcd@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-05-04 at 07:47 -0700, Stephen Hemminger wrote:
> Netlink please not sysfs. 

That seems like overkill in this case.

> also, any sysfs attributes have to handle unregistration issues.
>       ( sleep 900; read owner ) </sys/class/net/tun0/owner &
>       rmmod tun

That gets handled for you automatically...

[root@tylersburg ~]# ( sleep 900 ; read owner; echo $owner ) < /sys/class/net/tun0/owner &
[1] 4728
[root@tylersburg ~]# ./ip tuntap del tun0 mode tun
[root@tylersburg ~]# rmmod tun
[root@tylersburg ~]# killall sleep
-bash: line 28:  4729 Terminated              sleep 900
[root@tylersburg ~]# -bash: line 28: read: read error: 0: No such device

-- 
dwmw2

