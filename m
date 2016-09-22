From: Ben Greear <greearb@candelatech.com>
Subject: Fwd: Re: nfs broken on Fedora-24, 32-bit?
Date: Thu, 22 Sep 2016 10:35:53 -0700
Message-ID: <0c0194b3-43ff-4b74-355c-eec1443fd2bb@candelatech.com>
References: <08ad07ee-72e2-b478-d70d-87b08c24452f@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:33990 "EHLO
        mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965584AbcIVRfy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 13:35:54 -0400
Received: from [192.168.100.149] (firewall.candelatech.com [50.251.239.81])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail2.candelatech.com (Postfix) with ESMTPSA id D508240AC0B
        for <netdev@vger.kernel.org>; Thu, 22 Sep 2016 10:35:53 -0700 (PDT)
In-Reply-To: <08ad07ee-72e2-b478-d70d-87b08c24452f@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is probably not an NFS specific issue, though I guess possibly it is.

Forwarding to netdev in case someone wants to take a look at it.

Thanks,
Ben


-------- Forwarded Message --------
Subject: Re: nfs broken on Fedora-24, 32-bit?
Date: Fri, 16 Sep 2016 16:31:51 -0700
From: Ben Greear <greearb@candelatech.com>
Organization: Candela Technologies
To: Trond Myklebust <trondmy@primarydata.com>
CC: List Linux NFS Mailing <linux-nfs@vger.kernel.org>

On 09/15/2016 04:06 PM, Ben Greear wrote:
> On 09/15/2016 04:00 PM, Trond Myklebust wrote:
>> Hi Ben,
>>
>>> On Sep 15, 2016, at 18:32, Ben Greear <greearb@candelatech.com> wrote:
>>>
>>> I have a Fedora-24 machine mounting an NFS server running Fedora-13 (kernel 2.6.34.9-69.fc13.x86_64).
>>>
>>> F24 machine has this in /etc/fstab:
>>>
>>> 192.168.100.3:/mnt/d2 /mnt/d2                   nfs     nfsvers=3       0 0
>>>
>>> When I copy a file from f24-32 to the F-13 machine, the file size is the same,
>>> but the file is corrupted on the file server.  I see a different md5sum each time.
>>>
>>> Various other systems (F21, F19, etc) can all copy to the F13 machine fine.
>>>
>>> And, F24-64 machine can copy to the F13 machine fine.
>>>
>>> Anyone seen something similar?
>>
>> Do you know if the corruption is happening on the read()s or on the write()s? Do you, for instance get the same corruption if you copy from a local file on
>> the F-24 client to the server? ..or if you copy from a file on the server to a local directory on the F-24 client?
>>
>> Cheers
>>   Trond
>>
>
> Seems to be a write issue:
>
> # This is the nfs server:
>
> [greearb@fs3 candela_cdrom.5.3.5]$ md5sum gua-f21-32
> ad4073fa8b806bb82b85a645e21f5e67  gua-f21-32
> [greearb@fs3 candela_cdrom.5.3.5]$ md5sum ../greearb/tmp/gua-f21-32
> 582bfea0cc8cc52aa38dc0f5048d0156  ../greearb/tmp/gua-f21-32
> [greearb@fs3 candela_cdrom.5.3.5]$
>
>
> # This is the v-f24-32 client:
>
> greearb@v-f24-32 ~]$ cp /mnt/d2/pub/candela_cdrom.5.3.5/gua-f21-32 ./
> [greearb@v-f24-32 ~]$ md5sum gua-f21-32
> ad4073fa8b806bb82b85a645e21f5e67  gua-f21-32
> [greearb@v-f24-32 ~]$ cp gua-f21-32 /mnt/d2/pub/greearb/tmp/
> [greearb@v-f24-32 ~]$ md5sum /mnt/d2/pub/greearb/tmp/gua-f21-32
> ad4073fa8b806bb82b85a645e21f5e67  /mnt/d2/pub/greearb/tmp/gua-f21-32
>
>
> Interesting that the client reads back the file it copied over as if it were correct, but
> it shows up wrong on the nfs server.  Maybe it is just reading a local cache?
>
> Thanks,
> Ben
>

Here is some more info on this:

We can only reproduce this on virtual machines using the KVM infrastructure, and only
when we use the rtl8139 virtual hardware (in bridge mode).  With the e1000 virtual hardware
we cannot reproduce the problem.

Also, multiple different nfs servers (including much newer kernels) all show the same
behaviour with this broken nfs client.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
