From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next v3 0/4] net: ipv6: Improve user experience with
 multipath routes
Date: Mon, 30 Jan 2017 18:03:38 +0100
Message-ID: <b5948673-c30d-c4b3-1fcb-b5e984480b4a@6wind.com>
References: <1485559258-4856-1-git-send-email-dsa@cumulusnetworks.com>
 <588D3EB9.1070107@cumulusnetworks.com>
 <592be6dc-df0e-6185-ba6f-5acf5d042ae5@cumulusnetworks.com>
 <8f5334f0-20a3-0eb2-6baa-1fe8331ad2db@6wind.com>
 <0e9b2b4e-fc48-e21d-7b1f-3df45992e5e3@cumulusnetworks.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:35463 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751429AbdA3RDm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 12:03:42 -0500
Received: by mail-wm0-f50.google.com with SMTP id b65so41054213wmf.0
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 09:03:41 -0800 (PST)
In-Reply-To: <0e9b2b4e-fc48-e21d-7b1f-3df45992e5e3@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 30/01/2017 à 16:23, David Ahern a écrit :
> On 1/30/17 4:07 AM, Nicolas Dichtel wrote:
>> Le 29/01/2017 à 19:02, David Ahern a écrit :
>> [snip]
>>> Data centers are moving to L3, and multipath is a big part of that. Anyone who looks at ip -6 route enough knows it gets painful mentally pulling the individual routes into a single one.
>> I agree, but it's only an iproute2 problem. iproute2 could group routes to have
>> a better output, there is no need to have a kernel patch for this ;-)
>>
> 
> iproute2 is not the only rtnetlink user. The comment above uses ip show as an example. libnl has a workaround for IPv6 to update route objects versus replacing them - unnecessary complexity that does not need to replicated to iproute2, Quagga/FRR or python libraries implementing rtnetlink. Really, RTA_MULTIPATH support in notifications should have been added when multipath support was added to the IPv6. Patch 3 is mostly a refactoring of rt6_fill_node to fill in nexthop information. This could have been done 4+ years ago when RTA_MULTIPATH route adds was added to the stack.
> 
Like I said, I fully agree that RTA_MULTIPATH is better for the dump. For the
notifications, I'm not convinced. I did not this 4 years ago on purpose ;-)

I don't think that ipv4 is the right reference because the implementation is
really different. ipv6 is more flexible and this implies differences in the
notifications.
