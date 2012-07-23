From: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH net/for-next V1 1/1] IB/ipoib: break linkage to neighbouring
 system
Date: Mon, 23 Jul 2012 19:58:21 +0300
Message-ID: <500D82AD.2040508@mellanox.com>
References: <1342703938-29904-1-git-send-email-ogerlitz@mellanox.com> <1342703938-29904-2-git-send-email-ogerlitz@mellanox.com> <CAJZOPZ+kRcBjJgB_HaMqeuB5E-SLSqskgoaLZ_hvVx4KffHgpA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shlomo Pongratz <shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	<davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAJZOPZ+kRcBjJgB_HaMqeuB5E-SLSqskgoaLZ_hvVx4KffHgpA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 20/07/2012 18:49, Or Gerlitz wrote:
> On Thu, Jul 19, 2012 at 4:18 PM, Or Gerlitz<ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>  wrote:
>> From: Shlomo Pongratz<shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
>>
>> Dave Miller<davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>  provided a detailed description of why the
>> way IPoIB is using neighbours for its own ipoib_neigh struct is buggy:
> [...]
>
>> This patch aims to solve the race conditions found in the IPoIB driver.
>>
>> The patch breaks the connection between the core networking neighbour structure
>> and the ipoib_neigh structure. Except for avoiding the race, it allows to in
>> under a setup where SKBs carrying IP packets that don't have any associated
>> neighbour are transmitted through IPoIB.
>>
>> We add an ipoib_neigh hash table with 1024 buckets. The hash table key is the destin
>> hardware address. Thus the ipoib_neigh is fetched from the hash table and not
>> dereferenced from the stashed location at the neighbour structure. The hash table uses
>> both RCU and reference count mechanisms to guarantee that no ipoib_neigh instance is
>> ever deleted while in use.
>>
>> Fetching the ipoib_neigh structure instance from the hash also makes the special
>> code in ipoib_start_xmit that handles remote and local bonding failover redundant.
>>
>> Aged ipoib_neigh instances are deleted by a garbage collection task that runs every
>> 30 seconds and deletes every ipoib_neigh instance that was idle for at least 60
>> seconds. The deletion is safe since the ipoib_neigh instances are protected
>> using RCU and reference count mechanisms.
>
> Hi Dave, Roland, Eric
>
> So how does this look? in the right direction? anything that need to be fixed?

Sorry for the possible spam, but resending (last time forgot to put Eric 
on the "to" list so he might missed it, also added Christoph) - this is 
a fix for very long time bug in IPoIB and we do want it to be reviewed 
&& and hopefully accepted, or if needed get feedback and fix/change.

So, any further feedback? there was one feedback on V0, not to use read 
lock for RCU protected
hash table lookup, and it was addressed in V1.

Or.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
