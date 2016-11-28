From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [net,v2] neigh: fix the loop index error in neigh dump
Date: Sun, 27 Nov 2016 20:09:53 -0700
Message-ID: <6859d40b-0049-513a-6dc4-162d383ef7b9@cumulusnetworks.com>
References: <1480296725-5563-1-git-send-email-zhangshengju@cmss.chinamobile.com>
 <caa11887-00b9-d2f1-7c0b-5b5096b42f56@cumulusnetworks.com>
 <001c01d2491f$fcd53250$f67f96f0$@cmss.chinamobile.com>
 <6d1a324e-e29e-e2dd-a6fc-1e9b4455cb3d@cumulusnetworks.com>
 <001d01d24922$9a16b1e0$ce4415a0$@cmss.chinamobile.com>
 <a01fcd54-c0ed-9d05-743a-27592d845c56@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=gbk
Content-Transfer-Encoding: 8bit
To: =?UTF-8?B?5byg6IOc5Li+?= <zhangshengju@cmss.chinamobile.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:36082 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753884AbcK1DJ4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 22:09:56 -0500
Received: by mail-pf0-f177.google.com with SMTP id 189so21854208pfz.3
        for <netdev@vger.kernel.org>; Sun, 27 Nov 2016 19:09:56 -0800 (PST)
In-Reply-To: <a01fcd54-c0ed-9d05-743a-27592d845c56@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/27/16 7:56 PM, David Ahern wrote:
> On 11/27/16 7:53 PM, 张胜举 wrote:
>>
>>
>>> -----Original Message-----
>>> From: David Ahern [mailto:dsa@cumulusnetworks.com]
>>> Sent: Monday, November 28, 2016 10:39 AM
>>> To: 张胜举 <zhangshengju@cmss.chinamobile.com>;
>>> netdev@vger.kernel.org
>>> Subject: Re: [net,v2] neigh: fix the loop index error in neigh dump
>>>
>>> On 11/27/16 7:34 PM, 张胜举 wrote:
>>>>> -----Original Message-----
>>>>> From: David Ahern [mailto:dsa@cumulusnetworks.com]
>>>>> Sent: Monday, November 28, 2016 10:10 AM
>>>>> To: Zhang Shengju <zhangshengju@cmss.chinamobile.com>;
>>>>> netdev@vger.kernel.org
>>>>> Subject: Re: [net,v2] neigh: fix the loop index error in neigh dump
>>>>>
>>>>> On 11/27/16 6:32 PM, Zhang Shengju wrote:
>>>>>> Loop index in neigh dump function is not updated correctly under
>>>>>> some circumstances, this patch will fix it.
>>>>>
>>>>> What's an example?
>>>>
>>>> If dev is filtered out, the original code goes to next loop without
>>>> updating loop index 'idx'.
>>>
>>> And you have a use case with missing or redundant data? Or is your
>>> comment based on a review of code only?
>> It's on my code review. No use case currently,  this is uncommon to happen.
>>
>>
>>>
>>>>> You are completely rewriting the dump loops.
>>>>
>>>> I put 'idx++' into for loop,  so I replace 'goto' with 'continue'.
>>>> The other change is style related.
>>>
>>> A "fixes" should not include 'style related' changes.
>> Okay, I will send another version without style changes.
>>
> 
> Personally, I think you need to produce a use case that fails before sending another patch. I have not seen a problem with this code.
> 

And looking back at 3f0ae05d6f I should not have acked it (reviewed it too quickly while on PTO). Your change is a no-op because of what idx represents - the position in the hash list for devices relevant for the dump request. Same goes for the neigh dump so this patch is not needed.
