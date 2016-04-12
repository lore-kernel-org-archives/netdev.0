From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH for-next 2/2] net/mlx5: Update mlx5_ifc hardware features
Date: Tue, 12 Apr 2016 10:40:16 +0300
Message-ID: <CALzJLG8fXPLQ7tj2Nc7NbGpu4EuNoXTE+w8tDkwQ2F_AqgDtLA@mail.gmail.com>
References: <1460405422-8654-1-git-send-email-saeedm@mellanox.com>
 <1460405422-8654-3-git-send-email-saeedm@mellanox.com> <CAJ3xEMghu7ZB0YM8j_YJihpuNnDzOY2LU9-cTHwoWiBeYY7VPA@mail.gmail.com>
 <CALzJLG-PxUz9ov+cv4uiNSGpuxy0s9KamTvamV_g72SctqdhFA@mail.gmail.com>
 <CAJ3xEMhorMRsxtawjim9zoBn-zzoDXcMAJfHUqCZBNUbOKrMJA@mail.gmail.com>
 <20160412051537.GD25242@leon.nu> <CAJ3xEMijYrLvSmbNZp0B6AXqKGozz1rdZ58SCUP_09zOB6-2gQ@mail.gmail.com>
 <20160412060117.GA24649@leon.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Matan Barak <matanb@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Doug Ledford <dledford@redhat.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Leon Romanovsky <leonro@mellanox.com>,
	Tal Alon <talal@mellanox.com>
To: leon@leon.nu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f193.google.com ([209.85.161.193]:36598 "EHLO
	mail-yw0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756011AbcDLHkg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2016 03:40:36 -0400
Received: by mail-yw0-f193.google.com with SMTP id i125so1235167ywe.3
        for <netdev@vger.kernel.org>; Tue, 12 Apr 2016 00:40:36 -0700 (PDT)
In-Reply-To: <20160412060117.GA24649@leon.nu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 12, 2016 at 9:01 AM, Leon Romanovsky <leon@leon.nu> wrote:
> On Tue, Apr 12, 2016 at 08:36:21AM +0300, Or Gerlitz wrote:
>>
>> I understand your desire to get it down to zero, but it's not gonna
>> work, pick another target.
>
> Maybe you are right and the time will show, but now we (Saeed, Matan and me)
> are trying hard to achieve this goal.
>
>>
>> For example, the networking community has a fairly large rc activity
>> (I would say 10-20x
>> vs rdma), so when Dave does his "merge-rebases" for net-next over net
>> and linus tree
>> (4-5 times in a release), he has to this way or another solve
>> conflicts, yes! ditto for
>> Linus during merge windows and to some extent in rc times too.
>
> I don't see any harm in our desire to decrease work overhead from these
> busy people.
>
>>
>> > It won't help to anyone to split this commit to more than one patch.
>>
>> The commit change-log should make it clear what this is about, and it doesn't.
>> If you believe in something, state that clear, be precise.
>
> I agree.
>
>>
>> As Saeed admitted the shared code in the commit spans maybe 2% of it.
>>
>> The 1st commit deals with a field which is not used in the driver,
>> this is a cleanup
>> that you can do in rc (net) patch (remove the field all together) and
>> overall, w.o seeing

Or, I guess everybody here agrees that mlx5_ifc is our Connectx-4 pure
HW spec, written in C, isn't that cool ?
I see no harm updating our HW spec once in a kernel cycle revealing
new cool HW bits and interfaces
for anyone to use mlx5e/mlx5_core/mlx5_ib .. you name it.

Why would you break down this patch to many when no matter what you
do, at the end it would look the same ?
As Leon mentioned we MLNX maintainers prefer to update this file at
once when possible.

>
> I don't agree with your point that cleanup should go to RC.

I am with Leon on this one, the cleanup code is just cleanup for new
features to come,
it has nothing to do with RC (net).

>
>> the down-stream patches that depend on the newly introduced fields,
>> how do you know there aren't such (unused) bits in the 2nd commit?
>
> No, I don't know in advance, but the truth is that it doesn't bother
> anyone, because we are exposing our internal HW to kernel clients and
> doing it with minimal impact on the maintainers.

Yep, this is exactly what i am trying to say, there are no two ways to
describe/write (mlx5_ifc) code,
if it is a HW spec, why shouldn't it appear from day one ?
