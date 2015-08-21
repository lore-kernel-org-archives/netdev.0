From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: =?UTF-8?B?562U5aSNOg==?= [PATCH 1/5] net: add Hisilicon Network
 Subsystem support (config and documents)
Date: Fri, 21 Aug 2015 16:00:35 +0200
Message-ID: <2543796.7JthO5WCfI@wuerfel>
References: <1439548222-231611-1-git-send-email-liguozhu@hisilicon.com>
 <1536926.jEJjsM70Lj@wuerfel>
 <161EFA05D917D0419F95C4CAEEF86C1094E95FAA@SZXEMA504-MBS.china.huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "mark.rutland@arm.com" <mark.rutland@arm.com>,
 "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
 Salil Mehta <salil.mehta@huawei.com>,
 "pawel.moll@arm.com" <pawel.moll@arm.com>,
 "ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
 "catalin.marinas@arm.com" <catalin.marinas@arm.com>,
 Dingtianhong <dingtianhong@huawei.com>,
 "will.deacon@arm.com" <will.deacon@arm.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Linuxarm <linuxarm@huawei.com>,
 "paul.gortmaker@windriver.com" <paul.gortmaker@windriver.com>,
 "robh+dt@kernel.org" <robh+dt@kernel.org>,
 huangdaode <huangdaode@hisilicon.com>,
 "galak@codeaurora.org" <galak@codeaurora.org>,
 "zhangfei.gao@linaro.org" <zhangfei.gao@linaro.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "Zhuangyuzeng \(Yisen\)" <yisen.zhuang@huawei.com>,
 "davem@davemloft.net" <davem@davemloft.net>,
To: "Liguozhu (Kenneth)" <liguozhu@hisilicon.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <161EFA05D917D0419F95C4CAEEF86C1094E95FAA@SZXEMA504-MBS.china.huawei.com>
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

On Monday 17 August 2015 01:28:07 Liguozhu wrote:
> Thanks, Arnd. 
> 
> Regarding the ae-name: it is the name of the Acceleration Engine. It is provided
> by the BIOS according to the position and the feature enabled of the IP.
> So "soc0" means it is on SoC No. 0, while "n4" means it is running on 
>"Non-dsaf mode 4". Ideally, we should setup the rule to name it. But as I
> said in the patchset, the IP is original designed for a bare metal solution,
> it is worthless to export all modes and we are planning to add more mode
> for Linux itself in the IP in future version. So I think the better way is
> to leave it as a "name" but add more meaning in the future.

The name property is a bit awkward. The position is normally implied by
the location of the parent device in the DT, so you should not need that
at all and instead derive it elsewhere. You can also add strings to the
compatible property instead of this, to signify differences in the programming
that are based on how the IP block is used.
 
> Regarding the ae-opts: it is the initial value for the AE's runtime options,
> Currently, we have only "port number" (there are 6XGE+2GE port for a DSAF AE)
> as option. But for future version, we will add other options such as "enable
> Spanning Tree Protocol algorithm)" and so on. 

I think these can easily be converted into an index property and boolean
flags (present if true, absent otherwise) for additional features.
 
> Should I add these background to somewhere?

The binding document needs to list all supported configurations, if you
have a string property, describe specifically what strings are allowed
and what they mean, but better try to avoid strings altogether.

	Arnd
