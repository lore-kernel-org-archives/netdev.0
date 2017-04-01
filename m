From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next 0/4] ixgbe: enable Relaxed Order for ARM64
Date: Sat, 1 Apr 2017 16:49:41 +0800
Message-ID: <24292fb5-4b1d-f10f-080f-a7d967747e28@huawei.com>
References: <1491031554-19516-1-git-send-email-dingtianhong@huawei.com>
 <1491035962.3211.3.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, <catalin.marinas@arm.com>,
 <will.deacon@arm.com>, <mark.rutland@arm.com>, <robin.murphy@arm.com>,
 <davem@davemloft.net>, <alexander.duyck@gmail.com>,
 <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1491035962.3211.3.camel@intel.com>
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



On 2017/4/1 16:39, Jeff Kirsher wrote:
> On Sat, 2017-04-01 at 15:25 +0800, Ding Tianhong wrote:
>> The IXGBE_ALLOW_RELAXED_ORDER will enable Relaxed Ordering (RO) which
>> allows
>> transactions that do not have any order of completion requirements to
>> complete more efficiently compare to the Stricted Ordering (SO) for
>> ixbge
>> nic card. Some architecture will see high write-to-memory performance
>> when RO is
>> enabled on the data transactions just like the SPARC did.
>>
>> The aarch64 could both support Relaxed Ordering (RO) and Stricted
>> Ordering (SO),
>> so enable this config could get much more better performance, didn't
>> see any
>> adverse effects.
>>
>> The ARCH_WANT_RELAX_ORDER looks more general and would cause
>> misleading and
>> ambiguous, and till now only ixgbe could enable this "flag", so
>> rename this
>> config more specific.
>>
>> After discussion with the architecture maintainer, enable this config
>> in driver
>> looks more appropriate to compatible several architecture just like
>> SPARC and ARM64,
>> maybe we need more discussion about this, so let's begin by this
>> patch set.
>>
>> In the last patch 1a8b6d76(net:add one common config ...), Mao only
>> fix the
>> config name issue for 82599 pf, but the 82598 and 82599 vf still need
>> to be fixed,
>> so rename the config all in the drivers to instead of CONFIG_SPARC.
> 
> Thank you for at least CC'ing me, but please remember to also CC intel-
> wired-lan@lists.osuosl.org mailing list.  It make it easier for me to
> add your patches to my queue and makes it visible for the
> developers/validation people who will be reviewing and testing your
> changes.

Thanks for your reminder, fix it in next version.:)

> 
>>
>> Ding Tianhong (4):
>>   ixgbe: sparc: rename the ARCH_WANT_RELAX_ORDER to
>>     IXGBE_ALLOW_RELAXED_ORDER
>>   ixgbe: ixgbevf: Clear the CONFIG_SPARC for ixgbevf and 82598
>>   ixgbe: move IXGBE_ALLOW_RELAXED_ORDER from architecture to driver
>>   ixgbe: enable IXGBE_ALLOW_RELAXED_ORDER for ARM64
>>
>>  arch/Kconfig                                      | 3 ---
>>  arch/sparc/Kconfig                                | 1 -
>>  drivers/net/ethernet/intel/Kconfig                | 4 ++++
>>  drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c    | 4 ++--
>>  drivers/net/ethernet/intel/ixgbe/ixgbe_common.c   | 2 +-
>>  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 2 +-
>>  6 files changed, 8 insertions(+), 8 deletions(-)
