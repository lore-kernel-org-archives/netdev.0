From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next v7 0/4] net: Introduce protodown flag.
Date: Wed, 15 Jul 2015 10:34:04 -0700
Message-ID: <CAE4R7bCfu6a5H-niv2h47WTYEUcH9KYys4tpLzSTNpUAnq9Hcw@mail.gmail.com>
References: <1436906602-2958-1-git-send-email-anuradhak@cumulusnetworks.com>
 <CAE4R7bC2WPDfJiT7Av8YYUybvc0D1cakKBgDsL+mystM33guFw@mail.gmail.com> <20150715162434.GE588@gospo.home.greyhouse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Wilson Kok <wkok@cumulusnetworks.com>
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:34096 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751592AbbGOReY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2015 13:34:24 -0400
Received: by obre1 with SMTP id e1so31189927obr.1
        for <netdev@vger.kernel.org>; Wed, 15 Jul 2015 10:34:24 -0700 (PDT)
In-Reply-To: <20150715162434.GE588@gospo.home.greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 15, 2015 at 9:24 AM, Andy Gospodarek
<gospo@cumulusnetworks.com> wrote:
> On Tue, Jul 14, 2015 at 10:08:35PM -0700, Scott Feldman wrote:
>> On Tue, Jul 14, 2015 at 1:43 PM,  <anuradhak@cumulusnetworks.com> wrote:
>> > From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
>> >
>> > User space daemons can detect errors in the network that need to be
>> > notified to the switch device drivers.
>> >
>> > Drivers can react to this error state by doing a phy-down on the
>> > switch-port which would result in a carrier-off locally and on the directly
>> > connected switch. Doing that would prevent loops and black-holes in the
>> > network.
>>
>> Hi Anuradha,
>>
>> Since this is a switch-thingy, can you move this to switchdev port
>> attribute rather than adding another ndo op?  I know you started this
>> patch set before switchdev port attrs, but I think it's worthwhile
>> moving it to switchdev since clearly the use-case is switch device
>> drivers.   Let me know if you need help converting over to switchdev
>> port attr.
>
> If it is switchdev-only that would prevent people from using commodity
> hardware (classic servers + NICs) from being able to build something
> similar to what can be done with rocker.

That's not true.  There is nothing preventing a classic NIC driver
from implementing some/all switchdev ops if the device can do
forwarding offload or other switchy-things.

This patchset is about a switch feature (MLAG was the example
use-case), so let's move this under switchdev.
