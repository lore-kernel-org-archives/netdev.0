From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.18-rc4-mm[1,2,3] -- Network card not getting assigned an
 "eth" device name
Date: Mon, 28 Aug 2006 13:27:17 -0700 (PDT)
Message-ID: <20060828.132717.57158097.davem@davemloft.net>
References: <20060827.003800.95504796.davem@davemloft.net>
	<a44ae5cd0608280852p50e72241vff8e3ae101e94185@mail.gmail.com>
	<20060828120328.ae734de0.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: miles.lane@gmail.com, dcbw@redhat.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jeremy@goop.org, rml@novell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:23788
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751476AbWH1U1O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Aug 2006 16:27:14 -0400
To: akpm@osdl.org
In-Reply-To: <20060828120328.ae734de0.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@osdl.org>
Date: Mon, 28 Aug 2006 12:03:28 -0700

> grepping for `ioctl' gives:
> 
> ioctl(9, SIOCGIWNAME, 0xbfe38d8c)                 = -1 EINVAL (Invalid argument)
> ioctl(9, SIOCETHTOOL, 0xbfe38d2c)                 = 0
> ioctl(11, SIOCGIFHWADDR, {ifr_name="eth0", ???})  = -1 ENODEV (No such device)
> ioctl(11, SIOCGIFFLAGS, {ifr_name="eth0", ???})   = -1 ENODEV (No such device)
> 
> Perhaps you could generate the strace output for 2.6.18-rc5, grep that for
> ioctl, look for differences?  That initial SIOCGIWNAME failure is fishy.

That might help, but SIOCGIWNAME just gets a string that
says what wireless mode the device is in, not the device
name.  Althought NetworkManager might use this for something
interesting.

All of the interesting config calls are probably happening
via netlink, which doesn't get decoded by strace.

But changes via netlink can get traced by using "ip" in monitor mode,
try "ip monitor all" as root during such a NetworkManager run.
