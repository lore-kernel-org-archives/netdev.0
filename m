From: Ben Jencks <ben@bjencks.net>
Subject: `ip addr show' shows maximum of 56 addresses?
Date: Mon, 5 Dec 2011 16:12:14 -0500
Message-ID: <E46EABF5-E03F-4DF3-82C8-21017B0FD1A7@bjencks.net>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f53.google.com ([209.85.216.53]:60141 "EHLO
	mail-qw0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932159Ab1LEVMS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2011 16:12:18 -0500
Received: by qadb15 with SMTP id b15so3171267qad.19
        for <netdev@vger.kernel.org>; Mon, 05 Dec 2011 13:12:17 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm finding that ip addr show will only give me up to 56 addresses:

$ ip -6 addr show lo
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
$ for i in `seq 55` ; do sudo ip addr del fd9a:704e:4d65:136d::`printf '%x\n' $i`/128 dev lo ; done
$ ip addr show lo | grep inet6 | wc -l
56
$ ip addr show lo | grep ' ::1'
    inet6 ::1/128 scope host 
$ sudo ip addr add fd9a:704e:4d65:136d::`printf '%x\n' 56`/128 dev lo
$ ip addr show lo | grep inet6 | wc -l
56
$ ifconfig lo | grep inet6 | wc -l
57
$ ip addr show lo | grep ' ::1'
<no output>

It doesn't even help to specify the address explicitly:

$ ip addr show dev lo to ::1
<no output>

(Ubuntu kernel 2.6.32, tested with both distributed and latest git iproute2)

I searched for this issue, and even looked in the iproute2/ip/ipaddress.c and couldn't find any explicit limits. Is there a maximum netlink message size causing problems?

Sorry if this question is too user-ish for a dev list, but both linux-net and lartc looked dead.

Thanks,
-Ben