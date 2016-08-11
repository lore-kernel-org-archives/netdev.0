From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH] [v7] net: emac: emac gigabit ethernet controller driver
Date: Thu, 11 Aug 2016 11:03:17 -0500
Message-ID: <57ACA1C5.9040004@codeaurora.org>
References: <1470255143-3979-1-git-send-email-timur@codeaurora.org>
 <9ebb6cb7-c793-cd76-5283-c9a659d0398f@gmx.de>
 <57AA2001.2010904@codeaurora.org>
 <214dcbb7-0c3b-1e00-3e50-db513d77b10b@gmail.com>
 <57AA7ED0.9000707@codeaurora.org>
 <85b76eca-5473-6724-0c9d-7b6fa7677f50@gmail.com>
 <57AB589D.3010509@codeaurora.org>
 <0da01875-b55a-c0fd-bd5f-05bb41fbd7fc@gmail.com>
 <57AC8A3D.3010208@codeaurora.org> <57AC9575.3040204@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Florian Fainelli <f.fainelli@gmail.com>,
	Lino Sanfilippo <LinoSanfilippo@gmx.de>,
	netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-msm@vger.kernel.org, sdharia@codeaurora.org,
	shankerd@codeaurora.org, vikrams@codeaurora.org,
	cov@codeaurora.org, gavidov@codeaurora.org, robh+dt@kernel.org,
	andrew@lunn.ch, bjorn.andersson@linaro.org, mlangsdo@redhat.com,
	jcm@redhat.com, agross@codeaurora.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:41887 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932395AbcHKQDV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 12:03:21 -0400
In-Reply-To: <57AC9575.3040204@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timur Tabi wrote:
>
>>
>> The hang occurs with this loop in napi_disable():
>>
>>      while (test_and_set_bit(NAPI_STATE_SCHED, &n->state))
>>          msleep(1);
>>
>> This loop never exits.  Can you give me a clue as to what could be the
>> reason?
>
> I figured it out.  I cannot call napi_disable() twice in a row.  It's
> not smart enough to know that NAPI is already disabled.

I realized that I was going about this the wrong way.  Rather than try 
to protect the setting of adpt->rxbuf_size, I instead just calculate 
that value when RX path is configured, which is much cleaner.  This 
ensures that adpt->rxbuf_size is changed only when the interface is down.

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
