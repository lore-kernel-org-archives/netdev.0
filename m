From: Mason <slash.tmp@free.fr>
Subject: Re: [RFC PATCH v2 0/2] nb8800 suspend/resume support
Date: Wed, 2 Aug 2017 18:39:08 +0200
Message-ID: <a7b76388-7a7c-01e0-3966-ff7ebb4df799@free.fr>
References: <33d1ab47-6098-5e3f-8a3c-f72626d07113@free.fr>
 <aa8885b8-e6bb-3624-2bf9-0bb40505ac54@free.fr>
 <dd883398-1511-0bfd-972b-a11ef8709f0d@free.fr> <yw1xshhagexd.fsf@mansr.com>
 <9e8e12b1-74e2-8323-ec16-eebda46b2a3d@free.fr> <yw1xo9rygdyu.fsf@mansr.com>
 <6906dccf-bec9-0fc8-a34a-c39c05ada917@free.fr> <yw1xk22mgdcx.fsf@mansr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 8bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>
To: Mans Rullgard <mans@mansr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:4460 "EHLO smtp5-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752286AbdHBQjU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 2 Aug 2017 12:39:20 -0400
In-Reply-To: <yw1xk22mgdcx.fsf@mansr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/08/2017 18:10, Måns Rullgård wrote:

> Mason writes:
> 
>> On 02/08/2017 17:56, Måns Rullgård wrote:
>>
>>> What does the tango5 do if you flood it with packets faster than the
>>> kernel can keep up with?  That would make it hit the end of the rx
>>> chain, which is apparently what makes it miserable with the current dma
>>> stop code.
>>
>> The simplest way to test this would be sending tiny packets
>> as fast as possible, right? So ping -f on a GigE link should
>> fit the bill?
> 
> ping -f is limited to 100 packets per second.  Use something like iperf
> in UDP mode instead.

ping -f can go 100 times faster than 100 pps:

# ping -f -q -c 150000 -s 300 172.27.64.45
PING 172.27.64.45 (172.27.64.45) 300(328) bytes of data.

--- 172.27.64.45 ping statistics ---
150000 packets transmitted, 150000 received, 0% packet loss, time 15035ms
rtt min/avg/max/mdev = 0.065/0.084/0.537/0.014 ms, ipg/ewma 0.100/0.087 ms


150,000 packets in 15 seconds = 10,000 pps

(172.27.64.45 is the tango5 board)

Ergo, dealing with 10,000 packets per second does not hose RX.

Regards.
