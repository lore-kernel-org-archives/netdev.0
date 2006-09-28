From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 2/2] loopback: minor statistics optimization
Date: Wed, 27 Sep 2006 20:13:14 -0700
Message-ID: <451B3DCA.9010407@osdl.org>
References: <20060908111613.12c1f9b8@localhost.localdomain>	<20060908112056.7ef03bac@localhost.localdomain> <20060927.200459.13769170.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:33441 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965239AbWI1DNc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 23:13:32 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060927.200459.13769170.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Stephen Hemminger <shemminger@osdl.org>
> Date: Fri, 8 Sep 2006 11:20:56 -0700
>
>   
>> Minor loopback enhancements for 2.6.19
>>
>> The loopback device status structure is a singleton and doesn't
>> need to be allocated. Add ethtool_ops hooks to show checksum always on,
>> and make ethtool_ops const.
>>
>> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
>>     
>
> The ethtool bits are OK, but putting the loopback stats into
> the image adds nearly 200 bytes of .data section space on
> 64-bit.
>
> I don't really think it's that big of a deal to avoid the
> kmalloc() call.
>   
Yeah but doing the kmalloc is going to get a bigger chunk (rounded up),
anyway. The statistics should show up in BSS so it won't add to kernel size.

