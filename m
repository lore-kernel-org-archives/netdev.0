From: zhuyj <zyjzyj2000@gmail.com>
Subject: Re: in kernel 2.6.x, tun/tap nic supports vlan packets
Date: Thu, 17 Apr 2014 13:50:07 +0800
Message-ID: <534F6B8F.9000207@gmail.com>
References: <534F4C1E.1000006@gmail.com> <20140417050228.GC8243@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	joe@perches.com, julia.lawall@lip6.fr, dingtianhong@huawei.com,
	linux-kernel@vger.kernel.org, jasowang@redhat.com, mst@redhat.com,
	"Yang, Zhangle (Eric)" <Zhangle.Yang@windriver.com>,
	"Wu, Kuaikuai" <Kuaikuai.Wu@windriver.com>,
	"Tao, Yue" <Yue.Tao@windriver.com>, zhuyj <zyjzyj2000@gmail.com>
To: Willy Tarreau <w@1wt.eu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140417050228.GC8243@1wt.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/17/2014 01:02 PM, Willy Tarreau wrote:
> Hi Zhu,
>
> On Thu, Apr 17, 2014 at 11:35:58AM +0800, zhuyj wrote:
>> Hi, all
>>
>> In kernel 2.6.x, linux depends on nic vlan hardware acceleration to
>> insert/extract
>> vlan tag. In this scene, in kernel 2.6.x
>>
>>                   _____        ________
>>      A           |     | B    |        | C
>>   vlan packets-->| tap |----->|vlan nic|--->
>>                  |_____|      |________|
>>
>> We hope vlan packets pass through tap and vlan nic from A to c.
>> But in kernel 2.6.x, linux kernel can not extract vlan tag. It depends
>> on nic vlan hardware acceleration. It is well known that tap nic has no
>> vlan acceleration. So in the above scene, vlan packets can not be handled by
>> tap nic. These vlan packets will be discarded in B. They can not arrive
>> at C.
> It's not clear to me what you want to achieve. Are you trying to create
> vlan interfaces on top of a tap interface ? Eg: tap1.12, tap1.23 etc ?
Hi, Willy

Yes. These 2 patches are trying create vlan interfaces on top of a tap 
interface.

Zhu Yanjun
>
>> In kernel 3.x, linux can handle vlan packets. It does not depend on nic vlan
>> hardware acceleration. So the above scene can work well in kernel 3.x.
>>
>> To resolve the above in kernel 2.6.x, we simulated vlan hardware
>> acceleration in
>> tun/tap driver. Then followed the logic of commit commit 4fba4ca4
>> [vlan: Centralize handling of hardware acceleration] to modify the vlan
>> packets
>> process in kernel 2.6.x. In the end, the above scene can work well in
>> patched
>> kernel 2.6.x.
>>
>> Please comment on it. Any reply is appreciated.
>>
>> Hi, Willy
>>
>> These 2 patches are for linux2.6.x. These can work well here. Please
>> help to merge
>> linux 2.6.32.x. Thanks a lot.
> Well, 2.6.32.x is in deep freeze mode and it receives only critical fixes
> once in a while. While I can appreciate that the patch above might solve
> the issue you're facing, I'm wondering if there are not any acceptable
> workarounds for such a deep freeze kernel. You patch is not huge, but it
> definitely affects a working driver, and I wouldn't like risking to break
> the tap driver for other users, and I reall don't have the skills to audit
> it completely to ensure this is not the case. And if it breaks, I'll have
> to revert it or seek for some help on netdev.
>
> So I'd say that I'd rather not merge it unless I get an Acked-by from some
> netdev people who are willing to help in case of any future regression,
> which is unlikely but still possible.
>
> Just out of curiosity, what is the motivation for ongoing development on
> top of 2.6.32 ? Are there any important deployments that cannot upgrade
> for any specific reason ? I'm asking because most 2.6.32.x kernels that
> are stuffed into embedded boxes very likely come with their own number
> of in-house patches to add whatever feature is needed in such contexts,
> so I'm wondering why having this patch in mainline would help in your
> situation compared to having it into your own patch set only.
>
> Thanks,
> Willy
>
>
