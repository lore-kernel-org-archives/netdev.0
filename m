From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Subject: Re: [PATCH 0/5] Make /sys/class/net per net namespace objects belong
 to container
Date: Wed, 14 Sep 2016 20:24:09 -0700
Message-ID: <CAKdAkRTUjukVkXhMSPQ1YObRRVj0Fzvqivky_q34VCD9XRJdow@mail.gmail.com>
References: <1471386795-32918-1-git-send-email-dmitry.torokhov@gmail.com>
 <20160819.165917.2302741905893802825.davem@davemloft.net> <87zinvpx5s.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, Tejun Heo <tj@kernel.org>,
        lkml <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87zinvpx5s.fsf@x220.int.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 29, 2016 at 5:38 AM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
> David Miller <davem@davemloft.net> writes:
>
>> From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
>> Date: Tue, 16 Aug 2016 15:33:10 -0700
>>
>>> There are objects in /sys hierarchy (/sys/class/net/) that logically belong
>>> to a namespace/container. Unfortunately all sysfs objects start their life
>>> belonging to global root, and while we could change ownership manually,
>>> keeping tracks of all objects that come and go is cumbersome. It would
>>> be better if kernel created them using correct uid/gid from the beginning.
>>>
>>> This series changes kernfs to allow creating object's with arbitrary
>>> uid/gid, adds get_ownership() callback to ktype structure so subsystems
>>> could supply their own logic (likely tied to namespace support) for
>>> determining ownership of kobjects, and adjusts sysfs code to make use of
>>> this information. Lastly net-sysfs is adjusted to make sure that objects in
>>> net namespace are owned by the root user from the owning user namespace.
>>>
>>> Note that we do not adjust ownership of objects moved into a new namespace
>>> (as when moving a network device into a container) as userspace can easily
>>> do it.
>>
>> I need some domain experts to review this series please.
>
> I just came back from vacation and I will aim to take a look shortly.
>
> The big picture idea seems sensible.  Having a better ownship of sysfs
> files that are part of a network namespace.  I will have to look at the
> details to see if the implementation is similarly sensible.

Eric,

Did you find anything objectionable in the series or should I fix up
the !CONFIG_SYSFS error in networking patch and resubmit?

Thanks.

-- 
Dmitry
