From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: Re: tg3: regression of netdev stats
Date: Fri, 1 Mar 2013 18:30:14 -0800
Message-ID: <51316436.9090807@broadcom.com>
References: <878v67xnkr.fsf@devron.myhome.or.jp>
 <1362152836.6212.27.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=windows-1252;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: "OGAWA Hirofumi" <hirofumi@mail.parknet.co.jp>,
	davem@davemloft.net, netdev@vger.kernel.org
To: "Michael Chan" <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2352 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751528Ab3CBCa3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Mar 2013 21:30:29 -0500
In-Reply-To: <1362152836.6212.27.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 3/1/2013 7:47 AM, Michael Chan wrote:
> On Fri, 2013-03-01 at 22:21 +0900, OGAWA Hirofumi wrote:
>> Hi,
>>
>> f4a46d1f46a8fece34edd2023e054072b02e110d (tg3: Prevent spurious tx
>> timeout by setting carrier off before tx disable.) seems to add the bug.
>>
>> On 3.8.1 (I didn't use 3.7.x series), "ifconfig" commands doesn't show
>> any stats, i.e. all stats are zero.
>
> No stats on an active device transmitting and receiving packets?  I
> don't seem to see the same problem, but we'll look into this further.
> Thanks.
>

Hi Hirofumi,
I too am not able to see zero stats with 3.8.1. I ran traffic and stats 
go up as expected.

Are you certain that the interface was up? Did you run ifconfig with 
traffic running on the interface?

Thanks,
Nithin.


>> And bisect points the above commit.
>> In fact, reverting the above patch fixes the regression of netdev stats.
>>
>> This patch looks like strange, and I'm not sure what this want to do.
>> Any ideas?
>
> Every time we reset the device (ethtool, MTU change, etc), we need to
> turn off all the tx queues before resetting.  As soon as we turn off
> these queues, if we don't turn off carrier, a tx timeout may be
> triggered if it's been more than 5 seconds since the last transmit on
> any of the tx queues.  These tx timeouts cause unnecessary concern to
> the user.
>
>>
>> Well, anyway, this is bug report.
>>
>> Thanks.
>
>
