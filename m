From: Ilya Dryomov <idryomov@gmail.com>
Subject: Re: SOCK_MEMALLOC vs loopback
Date: Thu, 5 Mar 2015 10:09:59 +0300
Message-ID: <CAOi1vP8QWhqSSYPAOitx25AeKg0epkSTbez6R8ySz9kvO2nkAg@mail.gmail.com>
References: <CAOi1vP8tJTMhbCyKVD66pc_Tz7+aOS236KgvQnA-S63yv1P-sA@mail.gmail.com>
	<20150304200427.GQ3087@suse.de>
	<54F7D5A7.1060404@redhat.com>
	<54F7D7EA.6010303@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Mel Gorman <mgorman@suse.de>, ceph-devel@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	Sage Weil <sage@redhat.com>, NeilBrown <neilb@suse.de>,
	netdev@vger.kernel.org
To: Mike Christie <mchristi@redhat.com>
Return-path: <ceph-devel-owner@vger.kernel.org>
In-Reply-To: <54F7D7EA.6010303@redhat.com>
Sender: ceph-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 5, 2015 at 7:13 AM, Mike Christie <mchristi@redhat.com> wrote:
> On 03/04/2015 10:03 PM, Mike Christie wrote:
>> On 03/04/2015 02:04 PM, Mel Gorman wrote:
>>> > On Wed, Mar 04, 2015 at 09:38:48PM +0300, Ilya Dryomov wrote:
>>>> >> Hello,
>>>> >>
>>>> >> A short while ago Mike added a patch to libceph to set SOCK_MEMALLOC on
>>>> >> libceph sockets and PF_MEMALLOC around send/receive paths (commit
>>>> >> 89baaa570ab0, "libceph: use memalloc flags for net IO").  rbd is much
>>>> >> like nbd and is succeptible to all the same memory allocation
>>>> >> deadlocks, so it seemed like a step in the right direction.
>>>> >>
>>> >
>>> > The contract for SOCK_MEMALLOC is that it would only be used for temporary
>>> > allocations that were necessary for the system to make forward progress. In
>>> > the case of swap-over-NFS, it would only be used for transmitting
>>> > buffers that were necessary to write data to swap when there were no
>> Are upper layers like NFS/iSCSI/NBD/RBD supposed to know or track when
>> there are no other options (for example if a GFP_ATOMIC allocation
>> fails, then set the flags and retry the operation), or are they supposed
>> to be able to set the flags, send IO and let the network layer handle it?
>>
>
> Oh yeah, maybe I misunderstood you. Were you just saying we should not
> be using it for the configuration we are hitting the problem on?

NFS seems to be a bit of special case: its SOCK_MEMALLOC is set only
for swap sockets and it's a filesystem.  Mel's patch sets SOCK_MEMALLOC
on all nbd sockets unconditionally, but AFAICT there was a distinct
effort to make loopback nbd work (commit 48cf6061b302, "NBD: allow nbd
to be used locally").  I suspect it's currently broken in the same way.

Thanks,

                Ilya
