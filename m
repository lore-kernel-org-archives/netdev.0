From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH V2 4/7] net/mlx4_en: Set max rate-limit for a TC
Date: Tue, 27 Mar 2012 14:03:57 +0200
Message-ID: <4F71ACAD.7010803@mellanox.com>
References: <1332752874-8086-1-git-send-email-amirv@mellanox.com> <1332752874-8086-5-git-send-email-amirv@mellanox.com> <1332773163.3500.81.camel@deadeye> <CAJZOPZKGJ_nJt92THc+eRGnEXPZG+hX_d2=f56m7gB_Fv8K4Cg@mail.gmail.com> <4F70BB98.4090806@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <or.gerlitz@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	<netdev@vger.kernel.org>, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Oren Duer <oren@mellanox.com>,
	Amir Vadai <amirv@dev.mellanox.co.il>,
	Liran Liss <liranl@mellanox.com>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog112.obsmtp.com ([207.126.144.133]:55369 "HELO
	eu1sys200aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752897Ab2C0MGT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2012 08:06:19 -0400
In-Reply-To: <4F70BB98.4090806@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 03/26/2012 08:55 PM, John Fastabend wrote:
> On 3/26/2012 10:00 AM, Or Gerlitz wrote:
>> On Mon, Mar 26, 2012 at 4:46 PM, Ben Hutchings
>> <bhutchings@solarflare.com>  wrote:
>>>> We used sysfs since max bw isn't part of the ETS / DCBX NL support, and we're
>>>> open to other suggestions to add generic support for max bw, e.g add call to
>>>> the DCBX NL API.
>>
>>> netlink interfaces are generally easily extensible and it doesn't make
>>> sense to me to augment such an interface through sysfs.  Perhaps you're
>>> concerned that netlink extensions won't be supported in older kernel
>>> versions running your OOT driver?  That's unfortunate, but let's not
>>> standardise an ugly interface based on a temporary problem like that.
>>
>> As written above, that was done since ratelimit isn't part of ETS, we can
>> that through netlink extensions that you mentioned, if this is the preffered
>> way to go, David? Eric? Ben - could you provide pointer to these extensions?
>>
>> Or.
>> --
>
> I think I original suggested it didn't belong in DCBNL because it
> wasn't part of ETS (802.1Qaz). But it _is_ a traffic selection
> algorithm and could fall into the vendor specific part of 802.1Q.
>
> I would suggest either adding it as an option to mqprio to take
> a max bandwidth. The advantage here is it would be tied in with
> the usual QOS tooling 'tc'.
>
> # tc qdisc add dev eth3 root mqprio help
> Usage: ... mqprio [num_tc NUMBER] [map P0 P1 ...]
>                    [queues count1@offset1 count2@offset2 ...] [hw 1|0]
> 		  [max_rate rate@tc ...]
>
This could be elegant, but since tc here is a logical traffic class and
ratelimit in our context is an attribute of ETS TC, it could be
problematic.

>
> Or extending DCBNL being careful not to break backwards
> compatibility. I tend to think extending mqprio is cleaner but
> a DCBNL extension could likely work as well. Would need a
> 'DCBNL_IEEE_SET_MAXRATE' and 'DCBNL_IEEE_GET_MAXRATE' for this
> I expect.
I do prefer this option. I'm checking now if it is possible to add
infrastructure for a vendor specific netlink command. It could be
connected by lldpad to the vendor TLV in DCBX.

>
> .John

I will send a V3 of this patchset without the ratelimit patch, to make 
sure the patchset will get into net-next on time.

Thanks,
Amir
