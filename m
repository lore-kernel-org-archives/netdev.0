From: Mason <slash.tmp@free.fr>
Subject: Re: [RFC PATCH v1] net: ethernet: nb8800: Reset HW block in ndo_open
Date: Mon, 31 Jul 2017 13:49:45 +0200
Message-ID: <a5ef2294-2adf-743b-f877-144a8f3958b4@free.fr>
References: <823b1540-b528-bbd7-7f99-5dc39a08868a@sigmadesigns.com>
 <yw1xk22slemx.fsf@mansr.com>
 <c1bf54ee-8634-23a1-abda-55bc3fafe2a8@sigmadesigns.com>
 <yw1xfudgl7am.fsf@mansr.com> <446e3a95-80c3-0742-9cb1-69a8dfc9b1ae@free.fr>
 <yw1x7eyrlc3s.fsf@mansr.com> <f04a0cba-6c09-e9e4-f2d1-d8b2a7e276c9@free.fr>
 <4ff343de-41c7-c309-04dc-983b5fe3e066@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>,
        netdev <netdev@vger.kernel.org>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Mans Rullgard <mans@mansr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:45763 "EHLO smtp5-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750933AbdGaLt7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 31 Jul 2017 07:49:59 -0400
In-Reply-To: <4ff343de-41c7-c309-04dc-983b5fe3e066@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29/07/2017 17:18, Florian Fainelli wrote:

> On 07/29/2017 05:02 AM, Mason wrote:
>
>> I have identified a 100% reproducible flaw.
>> I have proposed a work-around that brings this down to 0
>> (tested 1000 cycles of link up / ping / link down).
> 
> Can you also try to get help from your HW resources to eventually help
> you find out what is going on here?

The patch I proposed /is/ based on the feedback from the HW team :-(
"Just reset the HW block, and everything will work as expected."

>> In my opinion, upstream should consider this work-around
>> for inclusion. I'd like to hear David's and Florian's
>> opinion on the topic. It's always a pain to maintain
>> out-of-tree patches.
> 
> I have to agree with Mans here that the commit message explanation is
> not good enough to understand how the RX path is hosed after a call to
> ndo_stop() it would be good, both for you and for the people maintaining
> this driver to understand what happens exactly so the fix is correct,
> understood and maintainable. The patch itself looks reasonable with the
> limited description given, but it's the description itself that needs
> changing.

I have logged all register reads/writes occurring while
nb8800_stop() is executing.



1) BOARD A -- EVERYTHING WORKS AS EXPECTED

# test_eth.sh 
[   13.293669] nb8800 26000.ethernet eth0: Link is Up - 1Gbps/Full - flow control rx/tx
172.27.64.1 : xmt/rcv/%loss = 1/1/0%, min/avg/max = 0.41/0.41/0.41
[   15.874627] nb8800_stop from __dev_close_many
[   15.879044] ++ETH++ gw32 reg=f0026020 val=00920000
[   15.883900] ++ETH++ gw32 reg=f0026020 val=80920000
[   15.888969] ++ETH++ gr32 reg=f0026024 val=0000ec00
[   15.893809] ++ETH++ gw32 reg=f0026020 val=04920000
[   15.898697] ++ETH++ gw32 reg=f0026020 val=84920000
[   15.903582] ++ETH++ gw32 reg=f0026020 val=00930000
[   15.908423] ++ETH++ gw32 reg=f0026020 val=80930000
[   15.913272] ++ETH++ gr32 reg=f0026024 val=00000000
[   15.918160] ++ETH++ gr8  reg=f0026004 val=2b
[   15.922459] ++ETH++ gw8  reg=f0026004 val=0b
[   15.926782] ++ETH++ gr8  reg=f0026044 val=81
[   15.931123] ++ETH++ gw8  reg=f0026044 val=85
[   15.935457] ++ETH++ gw32 reg=f002610c val=9de74000
[   15.940317] ++ETH++ gw32 reg=f0026100 val=005c0aff
[   15.945187] ENTER nb8800_irq
[   15.948077] ++ETH++ gr32 reg=f0026104 val=00000004
[   15.952887] ++ETH++ gw32 reg=f0026104 val=00000004
[   15.957697] ++ETH++ gr32 reg=f0026204 val=00000004
[   15.962507] ++ETH++ gw32 reg=f0026204 val=00000004
[   15.967316] ++ETH++ gw32 reg=f0026218 val=003cc4a4
[   15.972149] ENTER nb8800_irq
[   15.975039] ++ETH++ gr32 reg=f0026104 val=00000001
[   15.979848] ++ETH++ gw32 reg=f0026104 val=00000001
[   15.984658] ++ETH++ gr32 reg=f0026204 val=00000000
[   16.045509] ++ETH++ gw32 reg=f002610c val=9de74000
[   16.050329] ++ETH++ gw32 reg=f0026100 val=005c0aff
[   16.055150] ENTER nb8800_irq
[   16.058042] ++ETH++ gr32 reg=f0026104 val=00000004
[   16.062852] ++ETH++ gw32 reg=f0026104 val=00000004
[   16.067662] ++ETH++ gr32 reg=f0026204 val=00000004
[   16.072470] ++ETH++ gw32 reg=f0026204 val=00000004
[   16.077279] ++ETH++ gw32 reg=f0026218 val=003cc4a4
[   16.082100] ENTER nb8800_irq
[   16.084993] ++ETH++ gr32 reg=f0026104 val=00000001
[   16.089802] ++ETH++ gw32 reg=f0026104 val=00000001
[   16.094611] ++ETH++ gr32 reg=f0026204 val=00000000
[   16.099454] ++ETH++ gr8  reg=f0026004 val=0b
[   16.103752] ++ETH++ gw8  reg=f0026004 val=2b
[   16.108057] ++ETH++ gr8  reg=f0026044 val=85
[   16.112353] ++ETH++ gw8  reg=f0026044 val=81
[   16.116699] ++ETH++ gw32 reg=f002620c val=9f7b2000
[   16.121528] ++ETH++ gr8  reg=f0026004 val=2b
[   16.125827] ++ETH++ gw8  reg=f0026004 val=2a
[   16.130126] ++ETH++ gr32 reg=f0026100 val=00080afe
[   16.134945] ++ETH++ gr8  reg=f0026000 val=1d
[   16.139238] ++ETH++ gw8  reg=f0026000 val=1c
[   16.143534] ++ETH++ gw32 reg=f0026020 val=00920000
[   16.148363] ++ETH++ gw32 reg=f0026020 val=80920000
[   16.153209] ++ETH++ gr32 reg=f0026024 val=00000000
[   16.158027] ++ETH++ gw32 reg=f0026020 val=04920000
[   16.162856] ++ETH++ gw32 reg=f0026020 val=84920000
[   16.167702] ++ETH++ gw32 reg=f0026020 val=00930000
[   16.172531] ++ETH++ gw32 reg=f0026020 val=80930000
[   16.177377] ++ETH++ gr32 reg=f0026024 val=00000000
[   16.182338] nb8800 26000.ethernet eth0: Link is Down
[   16.187361] ++ETH++ gw32 reg=f0026020 val=00920000
[   16.192194] ++ETH++ gw32 reg=f0026020 val=80920000
[   16.197052] ++ETH++ gr32 reg=f0026024 val=00000000
[   16.201887] ++ETH++ gw32 reg=f0026020 val=00920000
[   16.206717] ++ETH++ gw32 reg=f0026020 val=80920000
[   16.211575] ++ETH++ gr32 reg=f0026024 val=00000000
[   16.216394] ++ETH++ gw32 reg=f0026020 val=00800000
[   16.221235] ++ETH++ gw32 reg=f0026020 val=80800000
[   16.226084] ++ETH++ gr32 reg=f0026024 val=00001000
[   16.230913] ++ETH++ gw32 reg=f0026020 val=04801800
[   16.235742] ++ETH++ gw32 reg=f0026020 val=84801800
[   16.240620] ++ETH++ gw32 reg=f0026020 val=00920000
[   16.245451] ++ETH++ gw32 reg=f0026020 val=80920000
[   16.250310] ++ETH++ gr32 reg=f0026024 val=00000000
[   16.255134] ++ETH++ gw32 reg=f0026020 val=00920000
[   16.259964] ++ETH++ gw32 reg=f0026020 val=80920000
[   16.264821] ++ETH++ gr32 reg=f0026024 val=00000000
[   16.269642] ++ETH++ gw32 reg=f0026020 val=00800000
[   16.274470] ++ETH++ gw32 reg=f0026020 val=80800000
[   16.279316] ++ETH++ gr32 reg=f0026024 val=00001800
[   16.284134] ++ETH++ gw32 reg=f0026020 val=04801800
[   16.288963] ++ETH++ gw32 reg=f0026020 val=84801800
[   16.293872] EXIT nb8800_stop
[   20.087916] nb8800 26000.ethernet eth0: Link is Up - 1Gbps/Full - flow control rx/tx
172.27.64.1 : xmt/rcv/%loss = 1/1/0%, min/avg/max = 0.27/0.27/0.27



1) BOARD B -- RX WEDGED AFTER nb8800_stop

# test_eth.sh 
[   26.369255] nb8800 26000.ethernet eth0: Link is Up - 1Gbps/Full - flow control rx/tx
172.27.64.1 : xmt/rcv/%loss = 1/1/0%, min/avg/max = 0.34/0.34/0.34
[   28.907583] nb8800_stop from __dev_close_many
[   28.911997] ++ETH++ gw32 reg=f0026020 val=00920000
[   28.916856] ++ETH++ gw32 reg=f0026020 val=80920000
[   28.921732] ++ETH++ gr32 reg=f0026024 val=0000ec00
[   28.926565] ++ETH++ gw32 reg=f0026020 val=04920000
[   28.931422] ++ETH++ gw32 reg=f0026020 val=84920000
[   28.936285] ++ETH++ gw32 reg=f0026020 val=00930000
[   28.941134] ++ETH++ gw32 reg=f0026020 val=80930000
[   28.945993] ++ETH++ gr32 reg=f0026024 val=00000000
[   28.950857] ++ETH++ gr8  reg=f0026004 val=2b
[   28.955161] ++ETH++ gw8  reg=f0026004 val=0b
[   28.959463] ++ETH++ gr8  reg=f0026044 val=81
[   28.963767] ++ETH++ gw8  reg=f0026044 val=85
[   28.968067] ++ETH++ gw32 reg=f002610c val=9eed8000
[   28.972896] ++ETH++ gw32 reg=f0026100 val=005c0aff
[   28.977731] ENTER nb8800_irq
[   28.980632] ++ETH++ gr32 reg=f0026104 val=00000004
[   28.985450] ++ETH++ gw32 reg=f0026104 val=00000004
[   28.990268] ++ETH++ gr32 reg=f0026204 val=00000004
[   28.995085] ++ETH++ gw32 reg=f0026204 val=00000004
[   28.999903] ++ETH++ gw32 reg=f0026218 val=003cc4a4
[   29.004730] ENTER nb8800_irq
[   29.007625] ++ETH++ gr32 reg=f0026104 val=00000001
[   29.012442] ++ETH++ gw32 reg=f0026104 val=00000001
[   29.017259] ++ETH++ gr32 reg=f0026204 val=00000000
[   29.077759] ++ETH++ gw32 reg=f002610c val=9eed8000
[   29.082590] ++ETH++ gw32 reg=f0026100 val=005c0aff
[   29.087422] ENTER nb8800_irq
[   29.090322] ++ETH++ gr32 reg=f0026104 val=00000004
[   29.095140] ++ETH++ gw32 reg=f0026104 val=00000004
[   29.099958] ++ETH++ gr32 reg=f0026204 val=00000004
[   29.104774] ++ETH++ gw32 reg=f0026204 val=00000004
[   29.109591] ++ETH++ gw32 reg=f0026218 val=003cc4a4
[   29.114415] ENTER nb8800_irq
[   29.117311] ++ETH++ gr32 reg=f0026104 val=00000001
[   29.122127] ++ETH++ gw32 reg=f0026104 val=00000001
[   29.126944] ++ETH++ gr32 reg=f0026204 val=00000000
[   29.187460] ++ETH++ gw32 reg=f002610c val=9eed8000
[   29.192291] ++ETH++ gw32 reg=f0026100 val=005c0aff
[   29.197123] ENTER nb8800_irq
[   29.198119] ++ETH++ gr8  reg=f0026004 val=0b
[   29.198121] ++ETH++ gw8  reg=f0026004 val=2b
[   29.198123] ++ETH++ gr8  reg=f0026044 val=85
[   29.198125] ++ETH++ gw8  reg=f0026044 val=81
[   29.198139] ++ETH++ gw32 reg=f002620c val=9d818000
[   29.198141] ++ETH++ gr8  reg=f0026004 val=2b
[   29.198143] ++ETH++ gw8  reg=f0026004 val=2a
[   29.198145] ++ETH++ gr32 reg=f0026100 val=00080afe
[   29.198147] ++ETH++ gr8  reg=f0026000 val=1d
[   29.198148] ++ETH++ gw8  reg=f0026000 val=1c
[   29.198151] ++ETH++ gw32 reg=f0026020 val=00920000
[   29.198163] ++ETH++ gw32 reg=f0026020 val=80920000
[   29.198193] ++ETH++ gr32 reg=f0026024 val=00000000
[   29.198195] ++ETH++ gw32 reg=f0026020 val=04920000
[   29.198207] ++ETH++ gw32 reg=f0026020 val=84920000
[   29.198237] ++ETH++ gw32 reg=f0026020 val=00930000
[   29.198249] ++ETH++ gw32 reg=f0026020 val=80930000
[   29.198279] ++ETH++ gr32 reg=f0026024 val=00000000
[   29.282484] ++ETH++ gr32 reg=f0026104 val=00000005
[   29.287301] ++ETH++ gw32 reg=f0026104 val=00000005
[   29.292118] ++ETH++ gr32 reg=f0026204 val=00000004
[   29.296935] ++ETH++ gw32 reg=f0026204 val=00000004
[   29.301752] ++ETH++ gw32 reg=f0026218 val=003cc4a4
[   29.306640] nb8800 26000.ethernet eth0: Link is Down
[   29.311664] ++ETH++ gw32 reg=f0026020 val=00920000
[   29.316508] ++ETH++ gw32 reg=f0026020 val=80920000
[   29.321363] ++ETH++ gr32 reg=f0026024 val=00000000
[   29.326193] ++ETH++ gw32 reg=f0026020 val=00920000
[   29.331031] ++ETH++ gw32 reg=f0026020 val=80920000
[   29.335885] ++ETH++ gr32 reg=f0026024 val=00000000
[   29.340712] ++ETH++ gw32 reg=f0026020 val=00800000
[   29.345550] ++ETH++ gw32 reg=f0026020 val=80800000
[   29.350405] ++ETH++ gr32 reg=f0026024 val=00001000
[   29.355234] ++ETH++ gw32 reg=f0026020 val=04801800
[   29.360069] ++ETH++ gw32 reg=f0026020 val=84801800
[   29.364940] ++ETH++ gw32 reg=f0026020 val=00920000
[   29.369777] ++ETH++ gw32 reg=f0026020 val=80920000
[   29.374635] ++ETH++ gr32 reg=f0026024 val=00000000
[   29.379462] ++ETH++ gw32 reg=f0026020 val=00920000
[   29.384300] ++ETH++ gw32 reg=f0026020 val=80920000
[   29.389153] ++ETH++ gr32 reg=f0026024 val=00000000
[   29.393982] ++ETH++ gw32 reg=f0026020 val=00800000
[   29.398817] ++ETH++ gw32 reg=f0026020 val=80800000
[   29.403674] ++ETH++ gr32 reg=f0026024 val=00001800
[   29.408499] ++ETH++ gw32 reg=f0026020 val=04801800
[   29.413337] ++ETH++ gw32 reg=f0026020 val=84801800
[   29.418245] EXIT nb8800_stop
[   33.644357] nb8800 26000.ethernet eth0: Link is Up - 1Gbps/Full - flow control rx/tx
172.27.64.1 : xmt/rcv/%loss = 1/0/100%


There are only small differences between these two logs.

1) Different TRANSMIT_DESCRIPTOR_ADDRESS (0x2610c)
=> Not unexpected

2) On BOARD B, an additional
[   29.187460] ++ETH++ gw32 reg=f002610c val=9eed8000
[   29.192291] ++ETH++ gw32 reg=f0026100 val=005c0aff
[   29.197123] ENTER nb8800_irq
=> Is it possible for the ISR to be running simultaneously on two cores?
0x26100 = TRANSMIT_CHANNEL_CONTROL

3) Different RECEIVE_DESCRIPTOR_ADDRESS (0x2620c)
=> Not unexpected

4) ON BOARD B, an additional
[   29.282484] ++ETH++ gr32 reg=f0026104 val=00000005
[   29.287301] ++ETH++ gw32 reg=f0026104 val=00000005
[   29.292118] ++ETH++ gr32 reg=f0026204 val=00000004
[   29.296935] ++ETH++ gw32 reg=f0026204 val=00000004
[   29.301752] ++ETH++ gw32 reg=f0026218 val=003cc4a4
0x26104 = TRANSMIT_CHANNEL_STATUS
0x26204 = RECEIVE_CHANNEL_STATUS
0x26218 = RECEIVE_INTERRUPT_TIME
=> BOARD A didn't have to deal with two TX interrupts at the same time,
though it did deal with 1 and 4 separately.




I need to look if some of these register accesses are
racing on different cores.

Regards.
