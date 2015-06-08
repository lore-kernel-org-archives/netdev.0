From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v5 1/2] Renesas Ethernet AVB driver proper
Date: Tue, 09 Jun 2015 00:44:16 +0300
Message-ID: <55760CB0.1020503@cogentembedded.com>
References: <1752433.KgeJV8aUGv@wasted.cogentembedded.com> <20150603.201204.761049104805679684.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, devicetree@vger.kernel.org,
	galak@codeaurora.org, netdev@vger.kernel.org,
	richardcochran@gmail.com, linux-sh@vger.kernel.org,
	mitsuhiro.kimura.kc@renesas.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <20150603.201204.761049104805679684.davem@davemloft.net>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 06/04/2015 06:12 AM, David Miller wrote:

>> +		/* Received network control queue */
>> +		if (ris0 & RIS0_FRF1) {
>> +			ravb_write(ndev, ~RIS0_FRF1, RIS0);
>> +			/* Timestamp of network control packets that is based
>> +			 * on IEEE802.1AS, is used time synchronization of PTP.
>> +			 * It should not be handled by NAPI scheduling, because
>> +			 * it needs to be received as soon as possible.
>> +			 */
>> +			ravb_rx(ndev, NULL, RAVB_NC);
>> +			result = IRQ_HANDLED;
>> +		}

> Nobody else makes this distinction, all packets should be processed
> via your NAPI path.

    I see.

> When I see people conditionally invoking netif_rx()
> vs. netif_receive_skb() in their packet receive routine, like
> conditional locking, it's a big red flag.

> Furthermore, you should pass the NAPI context into ravb_rx() and use

    I guess I should have one NAPI context per RX queue?

> it so that you can invoke napi_gro_receive() on all of the packets and
> therefore support GRO.

    Hmm, I don't think I have a hardware support for generic RX offload...
I'm still unsure what it is anyway -- is it used for IP packet defragmentation?

WBR, Sergei

