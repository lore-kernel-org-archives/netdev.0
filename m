From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH 1/2] [v4] net: emac: emac gigabit ethernet controller
 driver
Date: Fri, 15 Apr 2016 12:23:54 -0500
Message-ID: <571123AA.2070000@codeaurora.org>
References: <1460570393-19838-1-git-send-email-timur@codeaurora.org>
 <570EC541.6080603@gmail.com> <570FFB6B.5060305@codeaurora.org>
 <57100962.40404@gmail.com> <571012E6.6050303@codeaurora.org>
 <57102920.7000104@codeaurora.org>
 <CAL_JsqLJffKzvMZTSLf+OESufDjrcMBd27fP5yh1R61=irXxcg@mail.gmail.com>
 <57110C70.9090007@codeaurora.org>
 <CAL_Jsq+1ssgBHERNyBNhz=SDC5j20xjE8PWM5JCgWSvHCnGQyw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vikram Sethi <vikrams@codeaurora.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	linux-arm-msm <linux-arm-msm@vger.kernel.org>,
	Sagar Dharia <sdharia@codeaurora.org>,
	Shanker Donthineni <shankerd@codeaurora.org>,
	Greg Kroah-Hartman <greg@kroah.com>,
	Christopher Covington <cov@codeaurora.org>,
	Gilad Avidov <gavidov@codeaurora.org>,
	Andrew Lunn <andrew@lunn.ch>,
	Bjorn Andersson <bjorn.andersson@linaro.org>,
	Mark Langsdorf <mlangsdo@redhat.com>,
	Jon Masters <jcm@redhat.com>,
	Andy Gross <agross@codeaurora.org>,
	"David S. Miller" <davem@davemloft.net>
To: Rob Herring <robh+dt@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAL_Jsq+1ssgBHERNyBNhz=SDC5j20xjE8PWM5JCgWSvHCnGQyw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rob Herring wrote:
> You may only care about the size, but the binding has to handle the
> more complex case. Here's an example
>
> <0x0 0x2 0x0 0x1 0x0>
>
> dma address 0 (cell 0) maps to cpu (parent) address 0x2_00000000 (cell
> 1-2) and the range/size is 4G (cell 3-4).
>
> If you have the same base address, then use the same address. The core
> will calculate the mask based on the size. IIRC, we also handle ~0 as
> a special case to support 4G for #size-cell=1.

So the first thing I noticed is that Gilad had this:

	reg =   <0xfeb20000 0x10000>,
		<0xfeb36000 0x1000>,
		<0xfeb3c000 0x4000>,
		<0xfeb38000 0x400>;
	#address-cells = <0>;

Shouldn't address-cells have been 1 instead?

Ok, let me see if I get this right:

32-bit:

soc {
	#address-cells = <1>;
	#size-cells = <1>;

	emac0: qcom,emac@feb20000 {
		compatible = "qcom,fsm9900-emac";
		#address-cells = <1>;
		#size-cells = <1>;
		reg-names = "base", "csr", "ptp", "sgmii";
		reg =   <0xfeb20000 0x10000>,
			<0xfeb36000 0x1000>,
			<0xfeb3c000 0x4000>,
			<0xfeb38000 0x400>;
		dma-ranges = <0 0 0xffffffff>;
		interrupt-parent = <&emac0>;

64-bit

soc {
	#address-cells = <2>;
	#size-cells = <2>;

	emac0: qcom,emac@feb20000 {
		compatible = "qcom,fsm9900-emac";
		#address-cells = <2>;
		#size-cells = <2>;
		reg-names = "base", "csr", "ptp", "sgmii";
		reg =   <0 0xfeb20000 0 0x10000>,
			<0 0xfeb36000 0 0x1000>,
			<0 0xfeb3c000 0 0x4000>,
			<0 0xfeb38000 0 0x400>;
		dma-ranges = <0 0 0 0 0xffffffff 0xffffffff>;

This seems inelegant, though.

-- 
Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora
Forum, a Linux Foundation collaborative project.
