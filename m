From: Petri Gynther <pgynther@google.com>
Subject: Re: [PATCH net-next 0/7] net: bcmgenet: multiple Rx queues support
Date: Wed, 25 Mar 2015 15:53:44 -0700
Message-ID: <CAGXr9JH-iEE-d=pZvR1KOsK+URCxyXL-GW4JtaF49DEGZO56eg@mail.gmail.com>
References: <20150325193509.09C362201FB@puck.mtv.corp.google.com>
	<55133786.40500@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jaedon Shin <jaedon.shin@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f44.google.com ([209.85.192.44]:34546 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752425AbbCYWxp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 18:53:45 -0400
Received: by qgep97 with SMTP id p97so69242196qge.1
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2015 15:53:45 -0700 (PDT)
In-Reply-To: <55133786.40500@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

On Wed, Mar 25, 2015 at 3:32 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> On 25/03/15 12:35, Petri Gynther wrote:
>> Final patch set to add support for multiple Rx queues:
>> 1. remove priv->int0_mask and priv->int1_mask
>> 2. modify Tx ring int_enable and int_disable vectors
>> 3. simplify bcmgenet_init_dma()
>> 4. tweak init_umac()
>> 5. rework Tx NAPI code
>> 6. rework Rx NAPI code
>> 7. add support for multiple Rx queues
>>
>
> Looks very good, thanks for getting these change out! Now I suppose what
> we would need is some sort of ethtool rx-nfc API to allow flow
> configuration towards particular RX queues?
> --
> Florian

Thanks for the quick review. Yes, as the next step, we would need
ethtool rx-nfc API to allow Rx flow configuration to various Rx
queues. Also, Rx priority queues are still off by default:

[GENET_V3] = {
        .tx_queues = 4,
        .tx_bds_per_q = 32,
        .rx_queues = 0,
        .rx_bds_per_q = 0,

[GENET_V4] = {
        .tx_queues = 4,
        .tx_bds_per_q = 32,
        .rx_queues = 0,
        .rx_bds_per_q = 0,

-- Petri
