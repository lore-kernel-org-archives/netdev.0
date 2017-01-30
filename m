From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v3 0/4] net: ipv6: Improve user experience with
 multipath routes
Date: Mon, 30 Jan 2017 08:23:27 -0700
Message-ID: <0e9b2b4e-fc48-e21d-7b1f-3df45992e5e3@cumulusnetworks.com>
References: <1485559258-4856-1-git-send-email-dsa@cumulusnetworks.com>
 <588D3EB9.1070107@cumulusnetworks.com>
 <592be6dc-df0e-6185-ba6f-5acf5d042ae5@cumulusnetworks.com>
 <8f5334f0-20a3-0eb2-6baa-1fe8331ad2db@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com, Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:36173 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753715AbdA3PYB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 10:24:01 -0500
Received: by mail-pf0-f180.google.com with SMTP id 189so91259213pfu.3
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 07:23:28 -0800 (PST)
In-Reply-To: <8f5334f0-20a3-0eb2-6baa-1fe8331ad2db@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/30/17 4:07 AM, Nicolas Dichtel wrote:
> Le 29/01/2017 à 19:02, David Ahern a écrit :
> [snip]
>> Data centers are moving to L3, and multipath is a big part of that. Anyone who looks at ip -6 route enough knows it gets painful mentally pulling the individual routes into a single one.
> I agree, but it's only an iproute2 problem. iproute2 could group routes to have
> a better output, there is no need to have a kernel patch for this ;-)
> 

iproute2 is not the only rtnetlink user. The comment above uses ip show as an example. libnl has a workaround for IPv6 to update route objects versus replacing them - unnecessary complexity that does not need to replicated to iproute2, Quagga/FRR or python libraries implementing rtnetlink. Really, RTA_MULTIPATH support in notifications should have been added when multipath support was added to the IPv6. Patch 3 is mostly a refactoring of rt6_fill_node to fill in nexthop information. This could have been done 4+ years ago when RTA_MULTIPATH route adds was added to the stack.
