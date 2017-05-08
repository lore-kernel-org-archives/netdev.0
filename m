From: Waldemar Rymarkiewicz <waldemar.rymarkiewicz@gmail.com>
Subject: Re: Network cooling device and how to control NIC speed on thermal condition
Date: Mon, 8 May 2017 10:08:25 +0200
Message-ID: <CAHKzcENk8USj1kjFco=a+vdXeX-FycM1G4hPm6JnotEUtNi99Q@mail.gmail.com>
References: <CAHKzcEMQPQzg6PYCSuv7Ufad+4AZ2gnqMgz3-VH5NTeb_pv4zQ@mail.gmail.com>
 <20170425144501.0cfe27a5@lxorguk.ukuu.org.uk> <CAHKzcEO-75r5Gmew9x1eprh9ACf_NQKCHQg9svOLM1OmVX0JgQ@mail.gmail.com>
 <20170428115630.GG13231@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alan Cox <gnomes@lxorguk.ukuu.org.uk>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170428115630.GG13231@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 28 April 2017 at 13:56, Andrew Lunn <andrew@lunn.ch> wrote:
> Is that a realistic test? No traffic over the network? If you are
> hitting your thermal limit, to me that means one of two things:
>
> 1) The device is under very heavy load, consuming a lot of power to do
>    what it needs to to.
>
> 2) Your device is idle, no packets are flowing, but your thermal
>    design is wrong, so that it cannot dissipate enough heat.
>
> It seems to me, you are more interested in 1). But your quick test is
> more about 2).

The test was not realistic indeed, but it was rather about showing how
link speed correlates to temperature. In the test, I was not under any
thermal condition. But the same gain on the temperature we can achieve
when we hit hot temperature trip point and does not matter how heavy
the network traffic is. It's not said the source of heat is a heavy
network traffic. There can be several sources of heat on SoC.
However, the fact is that PHYs having active 1G/s link generate much
more heat than having 100M/s link independently from network traffic.


> I would be more interested in do quick tests of switching 8Gbps,
> 4Gbps, 2Gbps, 1Gbps, 512Mbps, 256Bps, ... What effect does this have
> on temperature?
>
>> So, throttling link speed can really help to dissipate heat
>> significantly when the platform is under threat.
>>
>> Renegotiating link speed costs something I agree, it also impacts user
>> experience, but such a thermal condition will not occur often I
>> believe.
>
> It is a heavy handed approach, and you have to be careful. There are
> some devices which don't work properly, e.g. if you try to negotiate
> 1000 half duplex, you might find the link just breaks.

That is a valuable remark. I definitely need to run some interoperability tests.

> Doing this via packet filtering, dropping packets, gives you a much
> finer grained control and is a lot less disruptive. But it assumes
> handling packets is what it causing you heat problems, not the links
> themselves.

Link speed manipulation is considered by me as one of a cooling
method, the way to maintain the temperature along with cpufreq, fan
etc. It's not said, the heat is caused by heavy network traffic
itself. So, packets filtering is not of my interests.

All cooling methods impact host only, but "net cooling" impacts remote
side in addition, which seems to me to be a problem sometimes. Also,
the moment of link renegotiation blocks rx/tx for upper layers, so the
user sees a pause when streaming a video for example. However, if a
system is under a thermal condition, does it really matter?


/Waldek
