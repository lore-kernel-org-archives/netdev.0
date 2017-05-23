From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net 1/3] vlan: Fix tcp checksums offloads for Q-in-Q vlan.
Date: Tue, 23 May 2017 08:59:45 -0400
Message-ID: <35dc2a59-7e6b-224d-49da-085d3f140fe7@redhat.com>
References: <1495114265-23368-1-git-send-email-vyasevic@redhat.com>
 <1495114265-23368-2-git-send-email-vyasevic@redhat.com>
 <20170522.195921.1033609103219347751.davem@davemloft.net>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, makita.toshiaki@lab.ntt.co.jp
To: David Miller <davem@davemloft.net>, vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50890 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751308AbdEWM7x (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 May 2017 08:59:53 -0400
In-Reply-To: <20170522.195921.1033609103219347751.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/22/2017 07:59 PM, David Miller wrote:
> From: Vladislav Yasevich <vyasevich@gmail.com>
> Date: Thu, 18 May 2017 09:31:03 -0400
> 
>> It appears that since commit 8cb65d000, Q-in-Q vlans have been
>> broken.  The series that commit is part of enabled TSO and checksum
>> offloading on Q-in-Q vlans.  However, most HW we support can't handle
>> it.  To work around the issue, the above commit added a function that
>> turns off offloads on Q-in-Q devices, but it left the checksum offload.
>> That will cause issues with most older devices that supprort very basic
>> checksum offload capabilities as well as some newer devices (we've
>> reproduced te problem with both be2net and bnx).
>>
>> To solve this for everyone, turn off checksum offloading feature
>> by default when sending Q-in-Q traffic.  Devices that are proven to
>> work can provided a corrected ndo_features_check implemetation.
>>
>> Fixes: 8cb65d000 ("net: Move check for multiple vlans to drivers")
>> CC: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
>> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
> 
> This is a tough one.  I can certainly sympathize with your frustration
> trying to track this down.
> 
> Clearing NETIF_F_HW_CSUM completely is the most conservative change.
> 
> However, for all the (perhaps many) cards upon which the checksumming
> does work properly in Q-in-Q situations, this change could be
> introducing non-trivial performance regressions.
> 
> So I think Toshiaki's suggestion to drop IP_CSUM and IPV6_CSUM is,
> on balance, the best way forward.
> 

Thanks.  I'll update and re-submit.

-vlad

> Thanks.
> 
