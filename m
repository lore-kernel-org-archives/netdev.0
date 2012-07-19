From: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH net/for-next V1 1/1] IB/ipoib: break linkage to neighbouring
 system
Date: Thu, 19 Jul 2012 19:20:41 +0300
Message-ID: <500833D9.8000001@mellanox.com>
References: <1342703938-29904-1-git-send-email-ogerlitz@mellanox.com> <1342703938-29904-2-git-send-email-ogerlitz@mellanox.com> <alpine.DEB.2.00.1207190938190.28115@router.home> <50082183.5000402@mellanox.com> <alpine.DEB.2.00.1207191023130.29808@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Shlomo Pongartz <shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	<davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.DEB.2.00.1207191023130.29808-sBS69tsa9Uj/9pzu0YdTqQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 7/19/2012 6:24 PM, Christoph Lameter wrote:
> On Thu, 19 Jul 2012, Shlomo Pongartz wrote:
>
>> The garbage collection and stale times follow the default ipv4/6 neigh.default.gc_yyy
>> sysctl values, for example
>>
>> net.ipv4.neigh.default.gc_interval = 30
>> net.ipv4.neigh.default.gc_stale_time = 60
>>
>> If given access to these values from IPoIB, we will be happy
>> to integrate them into that logic
>
> It looks like the values are hardcoded right now.

Two points here,

1s, they are indeed hard-coded since there's no define/enum
that holds their default values (or maybe we should add one now?), see
this code snippest from net/ipv4/arp.c

>         .gc_interval    = 30 * HZ,
>         .gc_thresh1     = 128,
>         .gc_thresh2     = 512,
>         .gc_thresh3     = 1024,

2nd, and even more interesting, the little challenge here is how
to integrate with the sysctl's that allow for changing these values,
the mechanism that uses neigh_sysctl_table in net/core/neighbour.c isn't
exported to the rest of the world. And there's no point to define new
sysctl entries just for managing the IPoIB neighbours, ideas welcome.


>> Please clarify what do you mean by group expiration.
>
> If you have neighbor expiration periods of 4 hrs and it is necessary to
> run the expiration logic then please expire all the neighbor entries due a
> certain period after that as well to avoid running the expiration again in
> the next minute or so.


This is still a bit unclear here... do you mean to say that at a certain 
point in time,
**all** entries need to be deleted irrelevant of their (jiffies) age? why?

> I guess the fuzz factor needs to scale depending on the expiration period.
>
>

and this is what happens now, the factor is 0.5, entry would be deleted when
if  (60m <= unused < 90s) holds

Or.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
