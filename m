From: David Ahern <dsahern@gmail.com>
Subject: Re: [RFC PATCH] net: ipv6: Make address flushing on ifdown optional
Date: Tue, 27 Jan 2015 20:21:58 -0700
Message-ID: <54C855D6.7050500@gmail.com>
References: <1421263039-96198-1-git-send-email-dsahern@gmail.com>		 <20150122224033.6e2db5ce@urahara>		 <1422015737.2824.8.camel@stressinduktion.org>		 <20150127045653.GB13164@gospo.home.greyhouse.net>	 <1422351861.13969.5.camel@stressinduktion.org> <54C7A6D6.8020805@gmail.com> <1422372523.13969.23.camel@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andy Gospodarek <gospo@cumulusnetworks.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:50451 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752222AbbA1DWA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 22:22:00 -0500
Received: by mail-ie0-f177.google.com with SMTP id vy18so19322956iec.8
        for <netdev@vger.kernel.org>; Tue, 27 Jan 2015 19:21:59 -0800 (PST)
In-Reply-To: <1422372523.13969.23.camel@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 01/27/2015 08:28 AM, Hannes Frederic Sowa wrote:
>>   From the discussion a second patch is needed to make sure DAD is done
>> on a link up if there is an address configured.
>
> Thank you!
>
> Let's see if the DAD patch isn't complex, maybe it is a candidate for
> stable?

Actually, DAD is done on a link up; you can see the notifications go out 
when the link is brought up:

18:46:28.519907 IP6 :: > ff02::1:ff00:10: ICMP6, neighbor solicitation, 
who has 2001:1::10, length 24
18:46:28.607650 IP6 :: > ff02::1:ff03:402: ICMP6, neighbor solicitation, 
who has fe80::1:2ff:fe03:402, length 24

So current top of tree works fine wrt DAD on addresses added when a link 
is down and then the link is brought up.

But, my previous patch does not re-send notifications on the up in a 
down-up cycle. I believe it is because the IFA_F_TENTATIVE flag is not 
set for the global address configured. I will address that in the 
revised patch.

David
