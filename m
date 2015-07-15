From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
Subject: Re: [PATCH net-next v7 0/4] net: Introduce protodown flag.
Date: Wed, 15 Jul 2015 08:53:30 -0700
Message-ID: <CACcJQnRb89XcEy7c42aNYrvG7SHAU7Lak_+Hj2rWyVeSqpzt6A@mail.gmail.com>
References: <1436906602-2958-1-git-send-email-anuradhak@cumulusnetworks.com>
	<CAE4R7bC2WPDfJiT7Av8YYUybvc0D1cakKBgDsL+mystM33guFw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Wilson Kok <wkok@cumulusnetworks.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:34461 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752135AbbGOPxc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2015 11:53:32 -0400
Received: by lagx9 with SMTP id x9so27377550lag.1
        for <netdev@vger.kernel.org>; Wed, 15 Jul 2015 08:53:30 -0700 (PDT)
In-Reply-To: <CAE4R7bC2WPDfJiT7Av8YYUybvc0D1cakKBgDsL+mystM33guFw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 14, 2015 at 10:08 PM, Scott Feldman <sfeldma@gmail.com> wrote:
> On Tue, Jul 14, 2015 at 1:43 PM,  <anuradhak@cumulusnetworks.com> wrote:
>> From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
>>
>> User space daemons can detect errors in the network that need to be
>> notified to the switch device drivers.
>>
>> Drivers can react to this error state by doing a phy-down on the
>> switch-port which would result in a carrier-off locally and on the directly
>> connected switch. Doing that would prevent loops and black-holes in the
>> network.
>
> Hi Anuradha,
>
> Since this is a switch-thingy, can you move this to switchdev port
> attribute rather than adding another ndo op?  I know you started this
> patch set before switchdev port attrs, but I think it's worthwhile
> moving it to switchdev since clearly the use-case is switch device
> drivers.   Let me know if you need help converting over to switchdev
> port attr.
>
> Also, is the sysfs interface necessary?  The netlink/iproute2
> interface seems sufficient.
>
> -scott

Yes, for the current use case (MLAG) it would be better to isolate the
changes to switchdev. Also if we go with the switchdev option are you
thinking about dropping the netdev->proto_down bool attribute
altogether and only keeping that info in the switch drivers that
support the op?

You are right, the sysfs is not necessary. I can make it RO and just
use it for displaying or drop it all together. What would you
recommend?

Anuradha.
