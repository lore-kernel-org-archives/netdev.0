From: Waldemar Rymarkiewicz <waldemar.rymarkiewicz@gmail.com>
Subject: Re: Network cooling device and how to control NIC speed on thermal condition
Date: Mon, 15 May 2017 16:14:16 +0200
Message-ID: <CAHKzcEOAD9wfPnjz4+ycUXCG=m4py7upP+Vyc-Kyrd3aiLBf9g@mail.gmail.com>
References: <CAHKzcEMQPQzg6PYCSuv7Ufad+4AZ2gnqMgz3-VH5NTeb_pv4zQ@mail.gmail.com>
 <20170425144501.0cfe27a5@lxorguk.ukuu.org.uk> <CAHKzcEO-75r5Gmew9x1eprh9ACf_NQKCHQg9svOLM1OmVX0JgQ@mail.gmail.com>
 <20170428115630.GG13231@lunn.ch> <CAHKzcENk8USj1kjFco=a+vdXeX-FycM1G4hPm6JnotEUtNi99Q@mail.gmail.com>
 <20170508140225.GD19995@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Alan Cox <gnomes@lxorguk.ukuu.org.uk>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170508140225.GD19995@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8 May 2017 at 16:02, Andrew Lunn <andrew@lunn.ch> wrote:
> Yes, this is true. I got an off-list email suggesting this power
> difference is very significant, more so than actually processing
> packets.

this is a reason I've started to discuss this topic. PHYS consume a
lot of power so from thermal perspective its a good candidate for a
cooling device.

>> All cooling methods impact host only, but "net cooling" impacts remote
>> side in addition, which seems to me to be a problem sometimes. Also,
>> the moment of link renegotiation blocks rx/tx for upper layers, so the
>> user sees a pause when streaming a video for example. However, if a
>> system is under a thermal condition, does it really matter?
>
> I don't know the cooling subsystem too well. Can you express a 'cost'
> for making a change, as well as the likely result in making the
> change. You might want to make the cost high, so it is used as a last
> resort if other methods cannot give enough cooling.

Because the cost is relatively high (user experience impact and risk
that we break the link with devices that cannot handle link reneg
properly) definitely it should be a last resort cooling method before
system shutdown.

Thermal framework by default shuts down the system when it reaches the
critical trip point, before we have a hot trip point. Normally, in the
system when you have a thermal zone defined, you also define several
trip points (struct of temp, hysteresis and type) and you map trip
point to the cooling device (cpu, clock, devfreq, fan or whatever you
implement). The thermal governor will respectively activate cooling
devices based on system temperature and trip<->cool_dev map to
maintain system temperature on a possible lowest level.

I also did more tests and actually implemented a prototype net_cooling
device, register it by eth driver. In my setup (a switch and 2 PC,
running iperf test, streaming video) all work pretty well (the link is
renegotiated and transfer continues), but I came to the conclusion,
that instead manipulating link speed I can modify advertised link
modes, excluding the highest speeds and let the PHY layer to reneg a
link. It's much safer.


/Waldek
