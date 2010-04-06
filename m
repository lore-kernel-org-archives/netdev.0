From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: net-next: 2.6.34-rc1 regression: panic when running diagnostic
 on interface with IPv6
Date: Mon, 5 Apr 2010 21:39:10 -0700
Message-ID: <20100405213910.2cbb75b9@nehalam>
References: <EA929A9653AAE14F841771FB1DE5A1365FE4E2E26C@rrsmsx501.amr.corp.intel.com>
	<20100405.161221.159637463.davem@davemloft.net>
	<EA929A9653AAE14F841771FB1DE5A1365FE4E2E334@rrsmsx501.amr.corp.intel.com>
	<20100405.165317.89399272.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: emil.s.tantilov@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57109 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751068Ab0DFEoR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Apr 2010 00:44:17 -0400
In-Reply-To: <20100405.165317.89399272.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I can not reproduce this with current net-next and e1000e.

Please recheck that you are running the right code.

# ip addr show dev eth3
6: eth3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 00:15:17:c3:a9:fb brd ff:ff:ff:ff:ff:ff
    inet6 2001:db8:0:f101::1/64 scope global 
       valid_lft forever preferred_lft forever
    inet6 fe80::215:17ff:fec3:a9fb/64 scope link 
       valid_lft forever preferred_lft forever
# ip addr show dev eth3
6: eth3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 00:15:17:c3:a9:fb brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.12/24 brd 192.168.1.255 scope global eth3
    inet6 2001:db8:0:f101::1/64 scope global 
       valid_lft forever preferred_lft forever
    inet6 fe80::215:17ff:fec3:a9fb/64 scope link 
       valid_lft forever preferred_lft forever

# ethtool -t eth3
The test result is PASS
The test extra info:
Register test  (offline)	 0
Eeprom test    (offline)	 0
Interrupt test (offline)	 0
Loopback test  (offline)	 0
Link test   (on/offline)	 0

No failures, no backtrace, nothing?

$ git log net/ipv6/addrconf.c

commit 4b97efdf392563bf03b4917a0b5add2df65de39a
Author: Patrick McHardy <kaber@trash.net>
Date:   Fri Mar 26 20:27:49 2010 -0700

    net: fix netlink address dumping in IPv4/IPv6
    
    When a dump is interrupted at the last device in a hash chain and
    then continued, "idx" won't get incremented past s_idx, so s_ip_idx
    is not reset when moving on to the next device. This means of all
    following devices only the last n - s_ip_idx addresses are dumped.
    
    Tested-by: Pawel Staszewski <pstaszewski@itcare.pl>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

commit b79d1d54cf0672f764402fe4711ef5306f917bd3
Author: David S. Miller <davem@davemloft.net>
Date:   Thu Mar 25 21:39:21 2010 -0700

    ipv6: Fix result generation in ipv6_get_ifaddr().
    
    Finishing naturally from hlist_for_each_entry(x, ...) does not result
    in 'x' being NULL.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

commit b54c9b98bbfb4836b1f7441c5a9db24affd3c2e9
Author: David S. Miller <davem@davemloft.net>
Date:   Thu Mar 25 21:25:30 2010 -0700

    ipv6: Preserve pervious behavior in ipv6_link_dev_addr().
    
    Use list_add_tail() to get the behavior we had before
    the list_head conversion for ipv6 address lists.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>
