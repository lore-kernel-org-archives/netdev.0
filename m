From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [RFC PATCH v2 1/2] net: af_packet support for direct ring access
 in user space
Date: Tue, 13 Jan 2015 17:05:58 +0100
Message-ID: <54B54266.4040205@redhat.com>
References: <20150113043509.29985.33515.stgit@nitbit.x32> <54B535E2.7040600@redhat.com> <54B540BB.2090507@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, danny.zhou@intel.com,
	nhorman@tuxdriver.com, john.ronciak@intel.com,
	hannes@stressinduktion.org, brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41377 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752998AbbAMQGa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jan 2015 11:06:30 -0500
In-Reply-To: <54B540BB.2090507@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/13/2015 04:58 PM, John Fastabend wrote:
> On 01/13/2015 07:12 AM, Daniel Borkmann wrote:
...
>> Any slight chance these 8 ndo ops could be further reduced? ;)
>
> Its possible we could collapse a few of these calls. I'll see if
> we can get it a bit smaller. Another option would be to put a
> a pointer to the set of ops in the net_device struct. Something
> like,
>
>      struct net_device {
>          ...
>          const struct af_packet_hw *afp_ops;
>          ...
>      }
>
>      struct af_packet_hw {
>          int (*ndo_split_queue_pairs)(struct net_device *dev,
>                           unsigned int qpairs_start_from,
>                           unsigned int qpairs_num,
>                           struct sock *sk);
>          ...
>      }

I think trying to collapse might be better than two indirections.

...
>> When this is being set here, above test in packet_release() and the chunk
>> quoted below in packet_mmap() are not guaranteed to work since we don't
>> test if some ndos are actually implemented by the driver. Seems a bit
>> fragile, I'm wondering if we should test this capability as a _whole_,
>> iow if all necessary functions to make this work are being provided by the
>> driver, e.g. flag the netdev as such and test for that instead.
>
> Sounds good to me, better than scattering ndo checks throughout. Also
> with a feature flag administrators could disable it easily.

Sounds good to me, thanks John!
