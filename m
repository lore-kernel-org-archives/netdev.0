From: David Ahern <dsahern@gmail.com>
Subject: why are IPv6 addresses removed on link down
Date: Mon, 12 Jan 2015 22:06:44 -0700
Message-ID: <54B4A7E4.7030301@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:63620 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751182AbbAMFGq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 00:06:46 -0500
Received: by mail-pa0-f49.google.com with SMTP id eu11so1357287pac.8
        for <netdev@vger.kernel.org>; Mon, 12 Jan 2015 21:06:45 -0800 (PST)
Received: from [10.20.182.148] (128-107-239-233.cisco.com. [128.107.239.233])
        by mx.google.com with ESMTPSA id u7sm7801197pdp.45.2015.01.12.21.06.44
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Jan 2015 21:06:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We noticed that IPv6 addresses are removed on a link down. e.g.,
   ip link set dev eth1


Looking at the code it appears to be this code path in addrconf.c:

         case NETDEV_DOWN:
         case NETDEV_UNREGISTER:
                 /*
                  *      Remove all addresses from this interface.
                  */
                 addrconf_ifdown(dev, event != NETDEV_DOWN);
                 break;

IPv4 addresses are NOT removed on a link down. Is there a particular 
reason IPv6 addresses are?

Thanks,
David
