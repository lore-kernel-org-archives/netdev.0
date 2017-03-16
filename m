From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: port mirror on dsa switches?
Date: Thu, 16 Mar 2017 12:48:58 -0700
Message-ID: <6d50e527-a2e1-5d63-1cb4-bea893fbeb9b@gmail.com>
References: <CAJGZr0JzRZHTkdKCqFrwAG5fj-j3Ez2DYVOygiE9oQ3BTHZ4FA@mail.gmail.com>
 <a4308ccd-4bd3-d8f5-e9d1-c6dcb16c57bc@gmail.com>
 <CAJGZr0+qyKppYr5mfAM5TOtD9RMKnrZTeCOhaBK1wV_sHdPL3A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Maxim Uvarov <muvarov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f177.google.com ([209.85.128.177]:32870 "EHLO
        mail-wr0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752987AbdCPTtD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 15:49:03 -0400
Received: by mail-wr0-f177.google.com with SMTP id u48so39202671wrc.0
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 12:49:02 -0700 (PDT)
In-Reply-To: <CAJGZr0+qyKppYr5mfAM5TOtD9RMKnrZTeCOhaBK1wV_sHdPL3A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/16/2017 12:43 PM, Maxim Uvarov wrote:
> 2017-03-16 19:47 GMT+03:00 Florian Fainelli <f.fainelli@gmail.com>:
>> Hi,
>>
>> On 03/16/2017 03:32 AM, Maxim Uvarov wrote:
>>> Hello,
>>>
>>> Some dsa switches can support port mirror in hardware. Does somebody
>>> have any idea how to
>>> work with it from linux side in generic way?
>>
>> It has been implemented with commit
>> f50f212749e8a28803af3628acbeb85ee0458ed5 ("net: dsa: Add plumbing for
>> port mirroring") and you can see an implementation example with the b53
>> driver.
>>
> 
> thanks, see that in newer kernel. It will be good to update doc with
> commands to use.
> I see from cover latter you mirrored eth1 to eth2. I  assume it's dsa
> ports names for b53?

Yes, DSA will refuse mirroring to network devices that are not ports of
the switch (arguable we could allow mirroring to master network device,
but that's TODO).

> Do I also need updated tc?

Yes you do need a reasonably recent iproute2, like 4.11 or something close.

> 
>> For a DSA driver you should be implementing port_mirror_add and
>> port_mirror_del operations which provide you with the necessary
>> information. Hopefully the switch you are working with (mv88e6xxx?) is
>> also supportable using that API, if not, please submit changes to extend it.
>>
>> Thanks!
>> --
>> Florian
> 
> Yes, I think it will match mv88e6xxx. Will try to play with it. Thanks a lot!
> 


-- 
Florian
