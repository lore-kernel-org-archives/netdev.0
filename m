From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next v2 0/2] net: ipv6: Improve user experience with
 multipath routes
Date: Fri, 27 Jan 2017 17:29:01 +0100
Message-ID: <f30ab203-47f9-e333-3552-bf5e2dbeaaf9@6wind.com>
References: <20170124.110616.2098461870069191491.davem@davemloft.net>
 <4024f547-7f26-ab52-df9d-a0509048c7ff@6wind.com>
 <c78afc85-8d18-0f63-68b3-63925e5d8c81@cumulusnetworks.com>
 <20170126.130054.2221154789287701062.davem@davemloft.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:37421 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755207AbdA0Q3F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 11:29:05 -0500
Received: by mail-wm0-f41.google.com with SMTP id c206so146749697wme.0
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2017 08:29:05 -0800 (PST)
In-Reply-To: <20170126.130054.2221154789287701062.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 26/01/2017 à 19:00, David Miller a écrit :
> From: David Ahern <dsa@cumulusnetworks.com>
[snip]
>> Quagga does not properly handle IPv6 multipath routes received from
>> the kernel. I checked this with debian/jessie version and our
>> version, and Donald reviewed the source. It is broken.
> 
> If this is true, quagga is asbolutely not an argument for this "breaking"
> something.  It doesn't break anything.
Ok, my tests also shows that quagga is buggy.
Let's change the way to advertise these routes.

It would be great to also use RTA_MULTIPATH when a route is deleted (like in
your patch 1/2).

Note that there is still a difference between ipv4 and ipv6: in ipv4 when a
nexthop is added/updated/removed, the whole route must be deleted and added
again. In IPv6, nexthop can be managed one by one.
It means that in ipv4, the full route is always dumped, which is not the case in
ipv6.
