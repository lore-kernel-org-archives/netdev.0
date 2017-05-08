From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC net-next 5/6] net: Delay initializations for
 lightweight devices
Date: Mon, 8 May 2017 10:31:50 -0700
Message-ID: <79cad243-51fc-cae4-633c-fd217c30a150@gmail.com>
References: <20170506160734.47084-1-dsahern@gmail.com>
 <20170506160734.47084-6-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, nicolas.dichtel@6wind.com
To: David Ahern <dsahern@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:32821 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754978AbdEHRb6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 13:31:58 -0400
Received: by mail-qk0-f193.google.com with SMTP id o85so11101191qkh.0
        for <netdev@vger.kernel.org>; Mon, 08 May 2017 10:31:58 -0700 (PDT)
In-Reply-To: <20170506160734.47084-6-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/06/2017 09:07 AM, David Ahern wrote:
> Delay ipv4 and ipv6 initializations on lightweight netdevices until an
> address is added to the device.
> 
> Skip sysctl initialization for neighbor path as well.

Yeah, thanks for including the sysctl initialization. One thing that my
earlier "L2 only" attempt attempted to solve as well, was to put the
IFF_NOIPV4 and IFF_NOIPV6 flags as volatile. In case you changed your
mind and ended-up needing IP stacks to be initialized, this ought to be
possible at some point. I did not get to test that part though.

AFAIR, some peculiar devices like 6lowpan (and to some extent the larger
802.15.4 family) may want to be IPv6 exclusively. This means we may have
a bit of overlap with flags like IFF_NOARP, (the proposed IFF_NOIPV6
before) and IFF_LWT_NETDEV.

Thanks!
-- 
Florian
