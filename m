From: Rob Herring <robh+dt@kernel.org>
Subject: Re: [PATCH 1/2] [v4] net: emac: emac gigabit ethernet controller driver
Date: Fri, 15 Apr 2016 10:59:07 -0500
Message-ID: <CAL_Jsq+1ssgBHERNyBNhz=SDC5j20xjE8PWM5JCgWSvHCnGQyw@mail.gmail.com>
References: <1460570393-19838-1-git-send-email-timur@codeaurora.org>
 <570EC541.6080603@gmail.com> <570FFB6B.5060305@codeaurora.org>
 <57100962.40404@gmail.com> <571012E6.6050303@codeaurora.org>
 <57102920.7000104@codeaurora.org> <CAL_JsqLJffKzvMZTSLf+OESufDjrcMBd27fP5yh1R61=irXxcg@mail.gmail.com>
 <57110C70.9090007@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
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
To: Timur Tabi <timur@codeaurora.org>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <57110C70.9090007@codeaurora.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 15, 2016 at 10:44 AM, Timur Tabi <timur@codeaurora.org> wrote:
> Rob Herring wrote:
>>>
>>> >
>>> >         dma-mask = <0 0xffffffff>;
>>> >
>>> >or
>>> >
>>> >         dma-mask = <0xffffffff 0xffffffff>;
>>
>> No. See dma-ranges.
>
>
> How exactly should I use dma-ranges?  I can't find any other drivers that
> queries that property and uses the result to call dma_set_mask.  I thought
> the dma-ranges property is intended to specify address translation.  I don't
> need to translate any address, I just need to know a single number.

You may only care about the size, but the binding has to handle the
more complex case. Here's an example

<0x0 0x2 0x0 0x1 0x0>

dma address 0 (cell 0) maps to cpu (parent) address 0x2_00000000 (cell
1-2) and the range/size is 4G (cell 3-4).

If you have the same base address, then use the same address. The core
will calculate the mask based on the size. IIRC, we also handle ~0 as
a special case to support 4G for #size-cell=1.

Rob
