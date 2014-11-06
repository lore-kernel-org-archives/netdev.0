From: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Subject: Re: bifurcated driver
Date: Thu, 06 Nov 2014 10:10:33 +0100
Message-ID: <545B3B09.10403@6wind.com>
References: <26FA93C7ED1EAA44AB77D62FBE1D27BA54C42C29@IRSMSX102.ger.corp.intel.com>
 <26FA93C7ED1EAA44AB77D62FBE1D27BA54C4620C@IRSMSX102.ger.corp.intel.com>
 <26FA93C7ED1EAA44AB77D62FBE1D27BA54C46444@IRSMSX102.ger.corp.intel.com>
 <4163036.7ZLDrAu3iM@xps13>
 <DFDF335405C17848924A094BC35766CF0A98FBC5@SHSMSX104.ccr.corp.intel.com>
 <545ACF39.5000507@6wind.com>
 <DFDF335405C17848924A094BC35766CF0A990522@SHSMSX104.ccr.corp.intel.com>
 <CAKfHP0VaCW_zBb9-uJYwwDQ-+sz-DZ=b6hcWn0HfMmMzhiOfUA@mail.gmail.com>
Reply-To: nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: "dev-VfR2kkLFssw@public.gmane.org" <dev-VfR2kkLFssw@public.gmane.org>, "Fastabend,
 John R" <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
 netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Alex Markuze <alex-I7wstvAgZDk@public.gmane.org>, "Zhou, Danny" <danny.zhou-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <dev-bounces-VfR2kkLFssw@public.gmane.org>
In-Reply-To: <CAKfHP0VaCW_zBb9-uJYwwDQ-+sz-DZ=b6hcWn0HfMmMzhiOfUA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <http://dpdk.org/ml/options/dev>,
 <mailto:dev-request-VfR2kkLFssw@public.gmane.org?subject=unsubscribe>
List-Archive: <http://dpdk.org/ml/archives/dev/>
List-Post: <mailto:dev-VfR2kkLFssw@public.gmane.org>
List-Help: <mailto:dev-request-VfR2kkLFssw@public.gmane.org?subject=help>
List-Subscribe: <http://dpdk.org/ml/listinfo/dev>,
 <mailto:dev-request-VfR2kkLFssw@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-VfR2kkLFssw@public.gmane.org
Sender: "dev" <dev-bounces-VfR2kkLFssw@public.gmane.org>
List-Id: netdev.vger.kernel.org

Also CC netdev, this thread may interest network folks.

Le 06/11/2014 09:13, Alex Markuze a =C3=A9crit :
> Danny sums up the issue perfectly IMHO.
> While both verbs and DPDK aim to provide generic user space networking,=
 the
> similarities end there.
> verbs and RDMA HW are closely coupled and behave differently then stand=
ard
> eth nics and are not related to netdev mechanisms.
>
> Or, welcome to this discussion.
>
> Those interested can read the IB spec's (+1K pages) available from
> openfabrics*.
> *https://www.openfabrics.org/index.php
>
>
>
>
> On Thu, Nov 6, 2014 at 6:45 AM, Zhou, Danny <danny.zhou-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> wrot=
e:
>
>> I roughly read libibverbs related code and relevant infiniband/rdma
>> documents, and found though
>> many concepts in libibverbs looks similar to bifurcated driver, but th=
ere
>> are still lots of differences as
>> illustrated below based on my understanding:
>>
>> 1) Queue pair defined in RDMA specification are abstract concept, wher=
e
>> the queue pairs term used in
>>    bifurcated driver are rx/tx queue pairs in the NIC.
>> 2) Bifurcated PMD in DPDK directly access NIC resources as a slave dri=
ver
>> (no NIC control), while libibverbs
>>    as a user space library rather than driver offloads certain operati=
ons
>> to kernel driver and NIC by invoking
>>    "verbs" APIs.
>> 3) Libibverbs invokes infiniband specific system calls to allow
>> user/kernel space communication based on
>>    "verbs" defined in infiniband/RDMA spec, while bifurcated driver bu=
ild
>> on top of af_packet module
>>    and new socket options to do things like hw queue split-off , map
>> certain pages on I/O space to user space
>>    operations, etc.
>> 4) There is a specific embedded MMU unit in Infiniband/RDMA to provide=
s
>> memory protection, while
>>    bifurcated driver uses IOMMU rather than NIC to provide memory
>> protection.
>>
>> IMHO, libibverbs and corresponding kernel modules/drivers are specific=
ally
>> designed and implemented for
>> direct access to RDMA hardware from userspace, and it highly depends o=
n
>> "verbs" related system calls
>> supported by infiniband/rdma mechanism in kernel, rather than netdev
>> mechanism that bifurcated driver
>> solution depends on.
>>
>>> -----Original Message-----
>>> From: Vincent JARDIN [mailto:vincent.jardin-pdR9zngts4EAvxtiuMwx3w@public.gmane.org]
>>> Sent: Thursday, November 06, 2014 9:31 AM
>>> To: Zhou, Danny
>>> Cc: Thomas Monjalon; dev-VfR2kkLFssw@public.gmane.org; Fastabend, John R; Or Gerlitz
>>> Subject: Re: [dpdk-dev] bifurcated driver
>>>
>>> +Or
>>>
>>> On 05/11/2014 23:48, Zhou, Danny wrote:
>>>> Hi Thomas,
>>>>
>>>> Thanks for sharing the links to ibverbs, I will take a close look at
>> it and compare it to bifurcated driver. My take
>>>> after a rough review is that idea is very much similar, but bifurcat=
ed
>> driver implementation is generic for any
>>>> Ethernet device based on existing af_packet mechanism, with extensio=
n
>> of exchanging the messages between
>>>> user space and kernel space driver.
>>>>
>>>> I have an internal document to summary the pros and cons of below
>> solutions, except for ibvers, but
>>>> will be adding it shortly.
>>>>
>>>> - igb_uio
>>>> - uio_pci_generic
>>>> - VFIO
>>>> - bifurcated driver
>>>>
>>>> Short answers to your questions:
>>>>>     - upstream status
>>>> Adding IOMMU based memory protection and generic descriptor
>> description support now, into version 2
>>>> kernel patches.
>>>>
>>>>>     - usable with kernel netdev
>>>> af_packet based, and relevant patchset will be submitted to netdev f=
or
>> sure.
>>>>
>>>>>     - usable in a vm
>>>> No, it does no coexist with SRIOV for number of reasons. but if you
>> pass-through a PF to a VM, it works perfect.
>>>>
>>>>>     - usable for Ethernet
>>>> It could work with all Ethernet NICs, as flow director is available
>> and NIC driver support new net_ops to split off
>>>> queue pairs for user space.
>>>>
>>>>>     - hardware requirements
>>>> No specific hardware requirements. All mainstream NICs have multiple
>> qpairs and flow director support.
>>>>
>>>>>     - security protection
>>>> Leverage IOMMU to provide memory protection on Intel platform. Other
>> archs provide similar memory protection
>>>> mechanism, so we only use arch-agnostic DMA memory allocation APIs i=
n
>> kernel to support memory protection.
>>>>
>>>>>     - performance
>>>> DPDK native performance on user space queues, as long as drop_en is
>> enabled to avoid head-of-line blocking.
>>>>
>>>> -Danny
>>>>
>>>>> -----Original Message-----
>>>>> From: Thomas Monjalon [mailto:thomas.monjalon-pdR9zngts4EAvxtiuMwx3w@public.gmane.org]
>>>>> Sent: Wednesday, November 05, 2014 9:01 PM
>>>>> To: Zhou, Danny
>>>>> Cc: dev-VfR2kkLFssw@public.gmane.org; Fastabend, John R
>>>>> Subject: Re: [dpdk-dev] bifurcated driver
>>>>>
>>>>> Hi Danny,
>>>>>
>>>>> 2014-10-31 17:36, O'driscoll, Tim:
>>>>>> Bifurcated Driver (Danny.Zhou-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org)
>>>>>
>>>>> Thanks for the presentation of bifurcated driver during the communi=
ty
>> call.
>>>>> I asked if you looked at ibverbs and you wanted a link to check.
>>>>> The kernel module is here:
>>>>>
>> http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/dr=
ivers/infiniband/core
>>>>> The userspace library:
>>>>>     http://git.kernel.org/cgit/libs/infiniband/libibverbs.git
>>>>>
>>>>> Extract from Kconfig:
>>>>> "
>>>>> config INFINIBAND_USER_ACCESS
>>>>>     tristate "InfiniBand userspace access (verbs and CM)"
>>>>>     select ANON_INODES
>>>>>     ---help---
>>>>>       Userspace InfiniBand access support.  This enables the
>>>>>       kernel side of userspace verbs and the userspace
>>>>>       communication manager (CM).  This allows userspace processes
>>>>>       to set up connections and directly access InfiniBand
>>>>>       hardware for fast-path operations.  You will also need
>>>>>       libibverbs, libibcm and a hardware driver library from
>>>>>       <http://www.openfabrics.org/git/>.
>>>>> "
>>>>>
>>>>> It seems to be close to the bifurcated driver needs.
>>>>> Not sure if it can solve the security issues if there is no dedicat=
ed
>> MMU
>>>>> in the NIC.
>>>>>
>>>>> I feel we should sum up pros and cons of
>>>>>     - igb_uio
>>>>>     - uio_pci_generic
>>>>>     - VFIO
>>>>>     - ibverbs
>>>>>     - bifurcated driver
>>>>> I suggest to consider these criterias:
>>>>>     - upstream status
>>>>>     - usable with kernel netdev
>>>>>     - usable in a vm
>>>>>     - usable for ethernet
>>>>>     - hardware requirements
>>>>>     - security protection
>>>>>     - performance
>>>>>
>>>>> --
>>>>> Thomas
>>
>>
