From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Reorder of packets
Date: Tue, 17 May 2016 07:28:08 -0700
Message-ID: <1463495288.18194.89.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CANKzZ6xn8yPyyS4dTYSFU643ru207voMfFP1gscC1npnF+jb6g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>,
	netem@lists.linux-foundation.org,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org
To: Tuvia Rosenberg <rtuvia197@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33380 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755385AbcEQO2L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2016 10:28:11 -0400
Received: by mail-pf0-f194.google.com with SMTP id y7so2120047pfb.0
        for <netdev@vger.kernel.org>; Tue, 17 May 2016 07:28:11 -0700 (PDT)
In-Reply-To: <CANKzZ6xn8yPyyS4dTYSFU643ru207voMfFP1gscC1npnF+jb6g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-05-17 at 14:45 +0300, Tuvia Rosenberg wrote:
> Hi,
> I need example of reordering incoming UPD/IP packets with netem
> command.
> Can someone write an example ?
> Thanks,Tuvia R.

Simple one would be :

# netem based setup, installed at receiver side only
ETH=eth0
IFB=ifb10
DELAY=200us
JITTER=100us

ip link add ifb10 numtxqueues $TXQ type ifb
ip link set dev $IFB up

tc qdisc del dev $ETH ingress 2>/dev/null
tc qdisc add dev $ETH ingress

tc filter add dev $ETH parent ffff: \
   protocol ip u32 match u32 0 0 flowid 1:1 \
	action mirred egress redirect dev $IFB

tc qdisc del dev $IFB root 2>/dev/null
tc qdisc add dev $IFB root netem limit 10000 delay $DELAY $JITTER
