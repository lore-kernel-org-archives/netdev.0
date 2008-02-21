From: Patrick McHardy <kaber@trash.net>
Subject: Re: New sparse warning in net/mac80211/debugfs_sta.c
Date: Thu, 21 Feb 2008 19:00:03 +0100
Message-ID: <47BDBC23.5080007@trash.net>
References: <1203586467.20345.14.camel@brick>	 <20080221.015743.222059206.davem@davemloft.net>	 <1203588079.20345.15.camel@brick>	 <20080221.020554.259219477.davem@davemloft.net>	 (sfid-20080221_100524_615638_119EBE24)  <1203589042.17534.145.camel@johannes.berg> <1203616486.7181.269.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	David Miller <davem@davemloft.net>, harvey.harrison@gmail.com,
	netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57125 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753475AbYBUSAW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2008 13:00:22 -0500
In-Reply-To: <1203616486.7181.269.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches wrote:
> On Thu, 2008-02-21 at 11:17 +0100, Johannes Berg wrote:
>   
>> Yeah, I saw that discussion. I think it's fine, it's just something we
>> need to be aware of. In fact, I Joe had a patch (that seems to have
>> gotten lost?) to make DECLARE_MAC_BUF() declare a structure with the u8
>> pointer in it instead to get type checking for the args, which would
>> make our code there not even compile, and imho rightfully so. I'll send
>> in a patch to fix this (via John) and Joe can resend his patch to get
>> typechecking there.
>>     
>
> This removes the __pure from print_mac, so reject as appropriate...
>
> Add some type safety to print_mac by using 
> struct print_mac_buf * instead of char *.

And adds back the overhead of two completely unnecessary
function calls to the VLAN fastpath. How about just
stopping this idiocy and reverting the appropriate patches
to bring back MAC_FMT and use it where appropriate?


