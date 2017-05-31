From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 0/9] mlxsw: Support firmware flash
Date: Wed, 31 May 2017 14:18:44 -0400 (EDT)
Message-ID: <20170531.141844.290562274024770237.davem@davemloft.net>
References: <20170523.113859.1803057381093280239.davem@davemloft.net>
        <0daa5c5a-377c-767f-ea19-26c1f22bd30c@mellanox.com>
        <CAJ3xEMi_U-139_EXfuT+d0PLyBOn6C+aWaGpFfmH6E8odhtvaw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yotamg@mellanox.com, Yuval.Mintz@cavium.com, jiri@resnulli.us,
        netdev@vger.kernel.org, idosch@mellanox.com, mlxsw@mellanox.com,
        bhutchings@solarflare.com
To: gerlitz.or@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42082 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751125AbdEaSSr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 14:18:47 -0400
In-Reply-To: <CAJ3xEMi_U-139_EXfuT+d0PLyBOn6C+aWaGpFfmH6E8odhtvaw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <gerlitz.or@gmail.com>
Date: Tue, 30 May 2017 23:32:22 +0300

> On Sun, May 28, 2017 at 10:26 AM, Yotam Gigi <yotamg@mellanox.com> wrote:
>> On 05/23/2017 06:38 PM, David Miller wrote:
>>> From: Yotam Gigi <yotamg@mellanox.com>
>>> Date: Tue, 23 May 2017 18:14:15 +0300
> 
>>>> Sorry, I am not sure I understand. You think that drivers should not implement
>>>> ethtool's flash_device callback anymore? do you have an alternative for
>>>> firmware flash?
> 
>>> As stated, export an MTD device.
> 
>> So, after we have been going over MTD, it seems like it does not fit our needs
>> at all.
> 
>> MTD device provides (erasable-)block access to a flash storage, where in our
>> case the firmware burn process is just pouring a binary BLOB into the device.
>> The driver is not aware of the internal storage used for storing the firmware as
>> it is not defined in our driver-hardware API.
>>
>> Needless to say that block access has no meaning in our case, so any solution
>> that will involve MTD device to burn our firmware (if there is a solution at
>> all) will be a workaround and will not fit MTD purpose.
>>
>> Apart for boot time firmware flash, which we have already pushed we would really
>> like to allow the user to ask for a specific firmware version. Do you have any
>> other solution for us apart from "ethtool -f"?
>>
>> This problem is even more relevant in the Mellanox HCA driver team, which would
>> like to use that code in order to burn the HCA firmware, but not intend to
>> trigger it on boot time, which means that must have a way for the user to
>> trigger it.
> 
> 
> Hi Dave,
> 
> We had few more emails on this thread with Jakub, and he's now happy
> with our replies, so where do we go from here? could you comment on
> Yotam's note.

Ok, use ethtool -f if you must.
