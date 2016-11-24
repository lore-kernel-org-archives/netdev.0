From: "Levy, Amir (Jer)" <amir.jer.levy@intel.com>
Subject: RE: [PATCH v9 0/8] thunderbolt: Introducing Thunderbolt(TM)
 Networking
Date: Thu, 24 Nov 2016 20:35:24 +0000
Message-ID: <E607265CB020454880711A6F96C05A03C0C9CE05@hasmsx107.ger.corp.intel.com>
References: <1478701208-4585-1-git-send-email-amir.jer.levy@intel.com>
 <20161109143632.GE6167@kw.sim.vm.gnt>
 <E607265CB020454880711A6F96C05A03B677E4C9@hasmsx107.ger.corp.intel.com>
 <20161115105920.GH6167@kw.sim.vm.gnt>
 <E607265CB020454880711A6F96C05A03BE2199EE@hasmsx108.ger.corp.intel.com>
 <20161118112007.GB1230@kw.sim.vm.gnt> <20161122172828.GB31492@kw.sim.vm.gnt>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
        "andreas.noever@gmail.com" <andreas.noever@gmail.com>,
        "bhelgaas@google.com" <bhelgaas@google.com>,
        "corbet@lwn.net" <corbet@lwn.net>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
        "mario_limonciello@dell.com" <mario_limonciello@dell.com>,
        thunderbolt-linux <thunderbolt-linux@intel.com>,
        "Westerberg, Mika" <mika.westerberg@intel.com>,
        "Winkler, Tomas" <tomas.winkler@intel.com>,
        "Zhang, Xiong Y" <xiong.y.zhang@intel.com>,
        "remi.rerolle@seagate.com" <remi.rerolle@seagate.com>
To: Simon Guinot <simon.guinot@sequanux.org>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20161122172828.GB31492@kw.sim.vm.gnt>
Content-Language: en-US
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 22 2016, 07:28 PM, Simon Guinot wrote:
> Hi Amir,
> 
> I tested the thunderbolt-icm driver (v9 series) on an Gigabyte 
> motherboard
> (Z170X-UD5 TH-CF) with a Thunderbolt 3 controller (Alpine Ridge 4C).
> 
> I can see that the network interface is well created when the 
> motherboard is connected to a MacBook Pro (Thunderbolt 2 or 3).
> 
> And here are the TCP bandwidths measured using the iperf3 benchmark:

AFAIK, in UD5, Thunderbolt 3 is installed on 4 lanes of PCI Express Gen 3,
which is good for performance.

> 
> - MacBook Pro Thunderbolt 2: 8.46Gbits/sec
> - MacBook Pro Thunderbolt 3: 11.8Gbits/sec
> 
> Are this results consistent with your expectations ?

Thunderbolt 2 - yes,
Thunderbolt 3 - we didn't check the bandwidth with MacBook Pro Thunderbolt 3 yet.
The bandwidth in Linux<->Linux and Linux<->Windows setups with Thunderbolt 3
is around 15G (one direction).

> 
> From the MacOS system interface on the MacBook Pro Thunderbolt 3, I 
> noticed that the interface appears as dual lane (2x 20Gb/sec). But 
> when two MacBook Pro are connected together, the interface appears as 
> single lane (1x 40Gb/sec). Is some lane bonding support missing in the 
> Linux implementation ?

At the moment the iCM doesn't lane bond the inter domain link.
This will be added in a future drop of the iCM once the networking BW will be such that requires the bonding.

> 
> Here are a couple of additional questions:
> 
> - When the network interface is created, there is no IP address
>   assigned (or negotiated ?) on the Linux side. But it is done on the
>   MacOS side. And in the Linux kernel logs I can also read the message:
>   "ready for ThunderboltIP negotiation". Is there something missing or
>   not working on the Linux side ? What is the correct way to configure
>   or negotiate the IP address. For my tests I did it manually...

This is not related to Thunderbolt, but to OS administration.
I usually use ZeroConf in any OS that support Thunderbolt Networking, but static IP also works.
"ready for ThunderboltIP negotiation" is an important part of the path establishment, but isn't related to IP address.

Thanks,
Amir
