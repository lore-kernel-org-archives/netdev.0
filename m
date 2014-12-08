From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH v8 3/3] net: hisilicon: new hip04 ethernet driver
Date: Mon, 8 Dec 2014 09:48:07 +0800
Message-ID: <54850357.802@huawei.com>
References: <1397869980-21187-1-git-send-email-zhangfei.gao@linaro.org>
 <5483C977.2060308@huawei.com> <54842298.2010007@suse.de>
 <2619239.NTtdNaZCJM@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mark.rutland@arm.com, devicetree@vger.kernel.org, f.fainelli@gmail.com,
 linux@arm.linux.org.uk, eric.dumazet@gmail.com,
 sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org,
 xuwei5@hisilicon.com, David.Laight@aculab.com,
 Zhangfei Gao <zhangfei.gao@linaro.org>, davem@davemloft.net,
 linux-arm-kernel@lists.infradead.org
To: Arnd Bergmann <arnd@arndb.de>, Alexander Graf <agraf@suse.de>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <2619239.NTtdNaZCJM@wuerfel>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On 2014/12/8 4:09, Arnd Bergmann wrote:
> On Sunday 07 December 2014 10:49:12 Alexander Graf wrote:
>> On 07.12.14 04:28, Ding Tianhong wrote:
>>> On 2014/12/7 8:42, Alexander Graf wrote:
>>>> On 19.04.14 03:13, Zhangfei Gao wrote:
>>>>> Support Hisilicon hip04 ethernet driver, including 100M / 1000M controller.
>>>>> The controller has no tx done interrupt, reclaim xmitted buffer in the poll.
>>>>>
>>>>> Signed-off-by: Zhangfei Gao <zhangfei.gao@linaro.org>
>>>>
>>>> Is this driver still supposed to go upstream? I presume this was the
>>>> last submission and it's been quite some time ago 
>>>>
>>>
>>> yes, it is really a long time, but The hip04 did not support tx irq, 
>>> we couldn't get any better idea to fix this defect, do you have any suggestion?
>>
>> Well, if hardware doesn't have a TX irq I don't see there's anything we
>> can do to fix that ;).
> 
> I don't know if it's related to the ethernet on hip01, but I would assume
> it is, and that platform is currently being submitted for inclusion, so
> I'd definitely hope to see this driver get merged too eventually.
> 
> IIRC, the last revision of the patch set had basically fixed the problem,
> except for a race that would still allow the napi poll function to exit
> with poll_complete() but a full queue of TX descriptors and no fallback
> to clean them up. There was also still an open question about whether or
> not the driver should use skb_orphan, but I may be misremembering that part.
>  
>> Dave, what's your take here? Should we keep a driver from going upstream
>> just because the hardware is partly broken? I'd really prefer to have an
>> upstream driver on that SoC rather than some random (eventually even
>> more broken) downstream code.
> 
> We can certainly have a slow driver for this hardware, and I'd much
> prefer slow over broken. I'd guess that some of the performance impact
> of the missing interrupts can now be offset with the xmit_more	 logic.
> 
> 	Arnd

Ok, if so, I can modify this patch set and send them again base on zhangfei's last version
just for reviewing.

Regards
Ding

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> .
> 
