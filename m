From: Mike Christie <mchristi@redhat.com>
Subject: Re: SOCK_MEMALLOC vs loopback
Date: Wed, 04 Mar 2015 22:13:30 -0600
Message-ID: <54F7D7EA.6010303@redhat.com>
References: <CAOi1vP8tJTMhbCyKVD66pc_Tz7+aOS236KgvQnA-S63yv1P-sA@mail.gmail.com> <20150304200427.GQ3087@suse.de> <54F7D5A7.1060404@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Cc: ceph-devel@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Sage Weil <sage@redhat.com>, NeilBrown <neilb@suse.de>,
	netdev@vger.kernel.org
To: Mel Gorman <mgorman@suse.de>, Ilya Dryomov <idryomov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36377 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752534AbbCEENi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Mar 2015 23:13:38 -0500
In-Reply-To: <54F7D5A7.1060404@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/04/2015 10:03 PM, Mike Christie wrote:
> On 03/04/2015 02:04 PM, Mel Gorman wrote:
>> > On Wed, Mar 04, 2015 at 09:38:48PM +0300, Ilya Dryomov wrote:
>>> >> Hello,
>>> >>
>>> >> A short while ago Mike added a patch to libceph to set SOCK_MEMALLOC on
>>> >> libceph sockets and PF_MEMALLOC around send/receive paths (commit
>>> >> 89baaa570ab0, "libceph: use memalloc flags for net IO").  rbd is much
>>> >> like nbd and is succeptible to all the same memory allocation
>>> >> deadlocks, so it seemed like a step in the right direction.
>>> >>
>> > 
>> > The contract for SOCK_MEMALLOC is that it would only be used for temporary
>> > allocations that were necessary for the system to make forward progress. In
>> > the case of swap-over-NFS, it would only be used for transmitting
>> > buffers that were necessary to write data to swap when there were no
> Are upper layers like NFS/iSCSI/NBD/RBD supposed to know or track when
> there are no other options (for example if a GFP_ATOMIC allocation
> fails, then set the flags and retry the operation), or are they supposed
> to be able to set the flags, send IO and let the network layer handle it?
> 

Oh yeah, maybe I misunderstood you. Were you just saying we should not
be using it for the configuration we are hitting the problem on?
