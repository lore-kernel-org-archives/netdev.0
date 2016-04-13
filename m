From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 1/2] [v4] net: emac: emac gigabit ethernet controller driver
Date: Wed, 13 Apr 2016 22:07:46 +0200
Message-ID: <87ega9gtm5.fsf@nemi.mork.no>
References: <201604140340.wQZLwsUk%fengguang.wu@intel.com>
	<570E9E8D.50007@codeaurora.org> <570EA09F.1070000@codeaurora.org>
	<570EA434.30007@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Shanker Donthineni <shankerd@codeaurora.org>,
	kbuild test robot <lkp@intel.com>, kbuild-all@01.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org, linux-arm-msm@vger.kernel.org,
	sdharia@codeaurora.org, Greg Kroah-Hartman <greg@kroah.com>,
	vikrams@codeaurora.org, cov@codeaurora.org, gavidov@codeaurora.org,
	Rob Herring <robh+dt@kernel.org>, andrew@lunn.ch,
	bjorn.andersson@linaro.org, Mark Langsdorf <mlangsdo@redhat.com>,
	Jon Masters <jcm@redhat.com>,
	Andy Gross <agross@codeaurora.org>,
	"David S. Miller" <davem@davemloft.net>
To: Timur Tabi <timur@codeaurora.org>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <570EA434.30007@codeaurora.org> (Timur Tabi's message of "Wed, 13
	Apr 2016 14:55:32 -0500")
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Timur Tabi <timur@codeaurora.org> writes:
> Shanker Donthineni wrote:
>>>> >>     drivers/net/ethernet/qualcomm/emac/emac-mac.c: In function =
'emac_mac_up':
>>>>>>>> >>>> >>drivers/net/ethernet/qualcomm/emac/emac-mac.c:1076:9: w=
arning: large integer implicitly truncated to unsigned type [-Woverflow=
]
>>>> >>       writel(~DIS_INT, adpt->base + EMAC_INT_STATUS);
>>> >
>>> >This doesn't happen on arm64, and I don't know how to fix it.  DIS=
_INT is defined as:
>>> >
>>> >     #define DIS_INT          BIT(31)
>>> >
>> Try with (1U<<31).
>>
>
> Except that Gilad was previously asked to use the BIT() macros:
>
> 	https://lkml.org/lkml/2015/12/15/797

So typecast it.

  writel((u32)~DIS_INT, adpt->base + EMAC_INT_STATUS);


I believe the reason you don't see this on arm64 is that the writel
macro includes the typecast there.  But it doesn't on x86_64


Bj=C3=B8rn
