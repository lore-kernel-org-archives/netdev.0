From: Schuyler Patton <spatton@ti.com>
Subject: Re: [PATCH v2 0/2] net: ethernet: ti: cpsw: delete rx_descs property
Date: Tue, 7 Jun 2016 10:26:32 -0500
Message-ID: <5756E7A8.6090703@ti.com>
References: <1465307976-12235-1-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <grygorii.strashko@ti.com>, <linux-omap@vger.kernel.org>,
	<netdev@vger.kernel.org>, <robh+dt@kernel.org>,
	<pawel.moll@arm.com>, <mark.rutland@arm.com>,
	<ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
	<bcousson@baylibre.com>, <tony@atomide.com>,
	<devicetree@vger.kernel.org>
To: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
	<mugunthanvnm@ti.com>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465307976-12235-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 06/07/2016 08:59 AM, Ivan Khoronzhuk wrote:
> There is no reason in rx_descs property because davinici_cpdma
> driver splits pool of descriptors equally between tx and rx channels.
> So, this patch series makes driver to use available number of
> descriptors for rx channels.

I agree with the idea of consolidating how the descriptors are defined 
because of
the two variable components, number and size of the pool can be 
confusing to
end users. I would like to request to change how it is being proposed here.

I think the number of descriptors should be left in the device tree 
source file as
is and remove the BD size variable and have the driver calculate the 
size of the
pool necessary to support the descriptor request. From an user 
perspective it is
easier I think to be able to list the number of descriptors necessary 
vs. the size
of the pool.

Since the patch series points out how it is used so in the driver so to 
make that
consistent is perhaps change rx_descs to total_descs.

Regards,
Schuyler
>
> Based on master branch
>
> Since v1:
> - separate device tree and driver patches
> - return number of rx buffers from cpdma driver
>
> Ivan Khoronzhuk (2):
>    net: ethernet: ti: cpsw: remove rx_descs property
>    Documentation: DT: cpsw: remove rx_descs property
>
>   Documentation/devicetree/bindings/net/cpsw.txt |  1 -
>   arch/arm/boot/dts/am33xx.dtsi                  |  1 -
>   arch/arm/boot/dts/am4372.dtsi                  |  1 -
>   arch/arm/boot/dts/dm814x.dtsi                  |  1 -
>   arch/arm/boot/dts/dra7.dtsi                    |  1 -
>   drivers/net/ethernet/ti/cpsw.c                 | 13 +++----------
>   drivers/net/ethernet/ti/cpsw.h                 |  1 -
>   drivers/net/ethernet/ti/davinci_cpdma.c        |  6 ++++++
>   drivers/net/ethernet/ti/davinci_cpdma.h        |  1 +
>   9 files changed, 10 insertions(+), 16 deletions(-)
>
