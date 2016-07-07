From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 00/10] NCSI Support
Date: Thu, 7 Jul 2016 16:44:02 +0300
Message-ID: <CAJ3xEMg_gCT4rE=U3uX5tjqRarCLukKT9K2iFjsrk_7gwmwNHA@mail.gmail.com>
References: <1467523953-18998-1-git-send-email-gwshan@linux.vnet.ibm.com>
 <CAJ3xEMjEup1VUeCr3g2Ry78HvprfnC6wjGd=MWjnMOLWdLyKdQ@mail.gmail.com>
 <20160705174433.GA73415@ast-mbp.thefacebook.com> <CAJ3xEMgRqa_=MmPyRmOU=hUAF3o6N5A0dToa6hSwSut6QvosKw@mail.gmail.com>
 <1467883056.27157.28.camel@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Gavin Shan <gwshan@linux.vnet.ibm.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, joel@jms.id.au,
	weixue@trustnetic.com, Yuval Itkin <yuvali@mellanox.com>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:34658 "EHLO
	mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752531AbcGGNoD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 09:44:03 -0400
Received: by mail-oi0-f47.google.com with SMTP id s66so23358902oif.1
        for <netdev@vger.kernel.org>; Thu, 07 Jul 2016 06:44:03 -0700 (PDT)
In-Reply-To: <1467883056.27157.28.camel@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 7, 2016 at 12:17 PM, Benjamin Herrenschmidt
<benh@kernel.crashing.org> wrote:
> On Thu, 2016-07-07 at 12:12 +0300, Or Gerlitz wrote:
>> On Tue, Jul 5, 2016 at 8:44 PM, Alexei Starovoitov
>> <alexei.starovoitov@gmail.com> wrote:
>> > On Mon, Jul 04, 2016 at 01:03:06AM +0300, Or Gerlitz wrote:
>>
>> > Or, since cx4 has ncsi as well, could you do a thorough review of this
>> > to make sure that it fits mellanox nics as well?
>>
>> Hi Alexei, all
>>
>> Yuval from our team who deals with host management did review on the
>> series, SB his feedback.
>>
>> 1. The initialization uses a single unicast MAC address which hints it
>> assumes that the management traffic is IPv4 only. The infrastructure
>> does not seem to be ready for IPv6 based management traffic.
>
> You mean the transfer of the MAC address from the BMC to the NIC for
> filtering incoming traffic ?

The initialization sequence uses "Set MAC Command" once and
initializes MAC[1] in the chosen NC-SI pass-through channel.
If IPv6 is used, then the BMC multicast address (derived from the
assigned IP address to the BMC) shall also be configured (after the IP
address is assigned), and some multicast filtering shall be set as
well.
