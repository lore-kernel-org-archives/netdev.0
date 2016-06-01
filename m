From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH 1/2] [v4] net: emac: emac gigabit ethernet controller
 driver
Date: Wed, 1 Jun 2016 17:27:52 -0500
Message-ID: <574F6168.3020802@codeaurora.org>
References: <1460570393-19838-1-git-send-email-timur@codeaurora.org>
 <570EC541.6080603@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-msm@vger.kernel.org, sdharia@codeaurora.org,
	Shanker Donthineni <shankerd@codeaurora.org>,
	Greg Kroah-Hartman <greg@kroah.com>, vikrams@codeaurora.org,
	cov@codeaurora.org, gavidov@codeaurora.org,
	Rob Herring <robh+dt@kernel.org>, andrew@lunn.ch,
	bjorn.andersson@linaro.org, Mark Langsdorf <mlangsdo@redhat.com>,
	Jon Masters <jcm@redhat.com>,
	Andy Gross <agross@codeaurora.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <570EC541.6080603@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Florian Fainelli wrote:
>> +/* Transmit the packet */
>> >+static int emac_start_xmit(struct sk_buff *skb, struct net_device *netdev)
>> >+{
>> >+	struct emac_adapter *adpt = netdev_priv(netdev);
>> >+
>> >+	return emac_mac_tx_buf_send(adpt, &adpt->tx_q, skb);

> I would inline emac_mac_tx_buf_send()'s body here to make it much easier
> to read and audit...

I'm close to submitting a v5 of this patchset.  The change to phylib has 
resulted in significant other changes.  I'm sure it's still not quite 
right, so I ask your patience in reviewing it.

However, I'm not sure inlining emac_mac_tx_buf_send() into 
emac_start_xmit() is good idea.  That would result in moving several 
functions from emac-mac.c into emac.c.  I'm concerned about maintaining 
the functional split between the two files.

-- 
Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora
Forum, a Linux Foundation collaborative project.
