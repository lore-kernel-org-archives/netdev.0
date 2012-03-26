From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH V2 4/7] net/mlx4_en: Set max rate-limit for a TC
Date: Mon, 26 Mar 2012 11:55:20 -0700
Message-ID: <4F70BB98.4090806@intel.com>
References: <1332752874-8086-1-git-send-email-amirv@mellanox.com> <1332752874-8086-5-git-send-email-amirv@mellanox.com> <1332773163.3500.81.camel@deadeye> <CAJZOPZKGJ_nJt92THc+eRGnEXPZG+hX_d2=f56m7gB_Fv8K4Cg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org,
	Roland Dreier <roland@purestorage.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Oren Duer <oren@mellanox.com>,
	Amir Vadai <amirv@dev.mellanox.co.il>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:17799 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932961Ab2CZSzV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Mar 2012 14:55:21 -0400
In-Reply-To: <CAJZOPZKGJ_nJt92THc+eRGnEXPZG+hX_d2=f56m7gB_Fv8K4Cg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/26/2012 10:00 AM, Or Gerlitz wrote:
> On Mon, Mar 26, 2012 at 4:46 PM, Ben Hutchings
> <bhutchings@solarflare.com> wrote:
>>> We used sysfs since max bw isn't part of the ETS / DCBX NL support, and we're
>>> open to other suggestions to add generic support for max bw, e.g add call to
>>> the DCBX NL API.
> 
>> netlink interfaces are generally easily extensible and it doesn't make
>> sense to me to augment such an interface through sysfs.  Perhaps you're
>> concerned that netlink extensions won't be supported in older kernel
>> versions running your OOT driver?  That's unfortunate, but let's not
>> standardise an ugly interface based on a temporary problem like that.
> 
> As written above, that was done since ratelimit isn't part of ETS, we can
> that through netlink extensions that you mentioned, if this is the preffered
> way to go, David? Eric? Ben - could you provide pointer to these extensions?
> 
> Or.
> --

I think I original suggested it didn't belong in DCBNL because it
wasn't part of ETS (802.1Qaz). But it _is_ a traffic selection
algorithm and could fall into the vendor specific part of 802.1Q.

I would suggest either adding it as an option to mqprio to take
a max bandwidth. The advantage here is it would be tied in with
the usual QOS tooling 'tc'.

# tc qdisc add dev eth3 root mqprio help
Usage: ... mqprio [num_tc NUMBER] [map P0 P1 ...]
                  [queues count1@offset1 count2@offset2 ...] [hw 1|0]
		  [max_rate rate@tc ...]


Or extending DCBNL being careful not to break backwards
compatibility. I tend to think extending mqprio is cleaner but
a DCBNL extension could likely work as well. Would need a
'DCBNL_IEEE_SET_MAXRATE' and 'DCBNL_IEEE_GET_MAXRATE' for this
I expect.

.John
