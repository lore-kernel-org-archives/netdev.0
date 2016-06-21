From: "Wei Hu (Xavier)" <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v10 08/22] IB/hns: Add icm support
Date: Tue, 21 Jun 2016 12:37:39 +0800
Message-ID: <5768C493.6000300@huawei.com>
References: <1466087730-54856-1-git-send-email-oulijun@huawei.com>
 <1466087730-54856-9-git-send-email-oulijun@huawei.com>
 <20160617095834.GA5408@leon.nu> <57677314.70909@huawei.com>
 <20160620060614.GC1172@leon.nu> <5767A004.4060808@huawei.com>
 <20160620092719.GE1172@leon.nu> <5767BBDF.6010309@huawei.com>
 <20160620130422.GA4526@leon.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	<sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	<davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	<jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	<linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <gongyangming-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<xiaokun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <tangchaofei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<haifeng.wei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <charles.chenxin-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160620130422.GA4526-2ukJVAZIZ/Y@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 2016/6/20 21:04, Leon Romanovsky wrote:
> On Mon, Jun 20, 2016 at 05:48:15PM +0800, Wei Hu (Xavier) wrote:
>>
>> On 2016/6/20 17:27, Leon Romanovsky wrote:
>>> On Mon, Jun 20, 2016 at 03:49:24PM +0800, Wei Hu (Xavier) wrote:
>>>> On 2016/6/20 14:06, Leon Romanovsky wrote:
>>>>> On Mon, Jun 20, 2016 at 12:37:40PM +0800, Wei Hu (Xavier) wrote:
>>>>>> On 2016/6/17 17:58, Leon Romanovsky wrote:
>>>>>>> On Thu, Jun 16, 2016 at 10:35:16PM +0800, Lijun Ou wrote:
>>>>>>>> This patch mainly added icm support for RoCE. It initializes i=
cm
>>>>>>>> which managers the relative memory blocks for RoCE. The data
>>>>>>>> structures of RoCE will be located in it. For example, CQ tabl=
e,
>>>>>>>> QP table and MTPT table so on.
>>>>>>>>
>>>>>>>> Signed-off-by: Wei Hu <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
>>>>>>>> Signed-off-by: Nenglong Zhao <zhaonenglong-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
>>>>>>>> Signed-off-by: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
>>>>>>>> ---
>>>>>>> <...>
>>>>>>>
>>>>>>>> +
>>>>> Another question which you didn't answer [1].
>>>>>
>>>>> "I wonder if you have the same needs for ICM as it is in mlx4 dev=
ice.
>>>>> Do you have firmware?"
>>>>>
>>>>> [1] http://marc.info/?l=3Dlinux-rdma&m=3D146545553104913&w=3D2
>>>> Hi, Leon
>>>>      Now we haven't firmware.
>>>>      But hardware still need memory for QPC\CQC\MTPT\mtt etc.
>>> ICM stands for InfiniHost (Interconnect) Context Memory is a specif=
ic
>>> memory place to share between host <-> FW and host <-> HW if HW is
>>> aware of specific structures.
>>>
>>> I assume that in your case, it is enough to allocate memory region =
and
>>> supply it to HW. Am I right?
>> For Our hardware,
>> 1. ICM has a memory management method, It's very good for QPC\CQC\MT=
PT\mtt
>> etc. we need it.
> You need special HW to leverage its. AFAIK it is Mellanox specific.
=46or our hardware, we use ICM to memory management, the memory shared=20
with host and HW.
QPC\CQC\MTPT\mtt has specific memory requirement.
QPC\CQC\MTPT need continuous memory. we use ICM to management the block=
=20
of memory. It's very good=EF=BC=81
>> 2. The meomry for QPC\CQC\MTPT\mtt only used for RoCE hardware and d=
river,
>> we don't want use MR.
> I didn't mean Infiniband MR, but memory region returned from standard
> allocation functions (kmalloc, ...).
>
>> 3. Now we haven't firmware, maybe we need it next version.
> You are always invited to add support once it will be needed, no need=
 to
> add it in advance.
>
> Thanks


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
