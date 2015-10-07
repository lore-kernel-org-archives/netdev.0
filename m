From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 3/4] net: Add IPv6 support to VRF device
Date: Wed, 7 Oct 2015 12:52:42 -0600
Message-ID: <561569FA.9090509@cumulusnetworks.com>
References: <1444236640-2410-1-git-send-email-dsa@cumulusnetworks.com>
 <1444236640-2410-4-git-send-email-dsa@cumulusnetworks.com>
 <CAHA+R7Pvt7ZiUMnseimJYV=PT2ArYu9VOpvp2qz00CDem_TM2Q@mail.gmail.com>
 <5615687B.4070405@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33473 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750824AbbJGSwk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 14:52:40 -0400
Received: by pacex6 with SMTP id ex6so29010760pac.0
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2015 11:52:40 -0700 (PDT)
In-Reply-To: <5615687B.4070405@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/7/15 12:46 PM, David Ahern wrote:
> On 10/7/15 12:42 PM, Cong Wang wrote:
>> On Wed, Oct 7, 2015 at 9:50 AM, David Ahern <dsa@cumulusnetworks.com>
>> wrote:
>>> Add support for IPv6 to VRF device driver. Implemenation parallels what
>>> has been done for IPv4.
>> [...]
>>> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
>>> index b9ebd0d18a52..c878a0bc2137 100644
>>> --- a/drivers/net/Kconfig
>>> +++ b/drivers/net/Kconfig
>>> @@ -300,6 +300,7 @@ config NET_VRF
>>>          tristate "Virtual Routing and Forwarding (Lite)"
>>>          depends on IP_MULTIPLE_TABLES && IPV6_MULTIPLE_TABLES
>>>          depends on NET_L3_MASTER_DEV
>>> +       depends on IPV6
>>
>> So vrf will stop functioning without IPV6? This doesn't look correct...
>>
>
> The new functionality does. The inter-module/builtin dependencies are a
> nightmare. I either make VRF device require IPV6 like the IPVLAN driver
> does or I split the module into 2 -- 1 for IPv4 and 1 for IPv6.

Actually, I can't split it into because a netdevice can only have 1 
master yet can have both IPv4 and IPv6 addresses. I just noticed how 
bonding has it defined:

config BONDING
         tristate "Bonding driver support"
         depends on INET
         depends on IPV6 || IPV6=n


Let me try that style with VRF.

David
