From: Michal Simek <monstr@monstr.eu>
Subject: Re: net: more accurate skb truesize - regression on Microblaze
Date: Tue, 10 Apr 2012 13:38:33 +0200
Message-ID: <4F841BB9.2030209@monstr.eu>
References: <4F83EB0E.4020104@monstr.eu>  <1334046444.3126.12.camel@edumazet-glaptop>  <1334046746.3126.13.camel@edumazet-glaptop>  <4F83F166.4010208@monstr.eu> <1334057529.3126.90.camel@edumazet-glaptop>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	John Williams <john.williams@petalogix.com>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:57712 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751398Ab2DJLii (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 07:38:38 -0400
Received: by eekc41 with SMTP id c41so1295609eek.19
        for <netdev@vger.kernel.org>; Tue, 10 Apr 2012 04:38:37 -0700 (PDT)
In-Reply-To: <1334057529.3126.90.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/10/2012 01:32 PM, Eric Dumazet wrote:
> On Tue, 2012-04-10 at 10:37 +0200, Michal Simek wrote:
>> On 04/10/2012 10:32 AM, Eric Dumazet wrote:
>>> On Tue, 2012-04-10 at 10:27 +0200, Eric Dumazet wrote:
>>>
>>>> BTW, some NIC drivers are known to provide fat skb in their rx path, and
>>>> need to be fixed as well. (Some others just lie about skb->truesize to
>>>> avoid the tcp slowdown, see my previous iwlwifi patch)
>>>>
>>>>
>>>
>>> What is the driver you currently use on your platform ?
>>
>> Using Xilinx ll_temac(in mainline) and axi_emac.
>>
>
> ll_temac allocates XTE_MAX_JUMBO_FRAME_SIZE frames, even for MTU=1500 ?

yes.

>
> Trying to allocate smaller packets would definitely help your tcp
> receiver performance and overall reliability  (order-0 allocations
> instead of order-2)

There is long history for ll_temac and axi emac drivers. and if you compare
them they are very similar with similar bugs.
In our distribution we are using older ll_temac driver where this is fixed.
Performance is much higher if you allocate buffers for actual mtu.

Thanks,
Michal

P.S.: Our plan is to start to use mainline drivers and fixing them to get
the same performance as we have with old one. It is one my todo list.


-- 
Michal Simek, Ing. (M.Eng)
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel 2.6 Microblaze Linux - http://www.monstr.eu/fdt/
Microblaze U-BOOT custodian
