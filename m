From: nolan <nolan@cumulusnetworks.com>
Subject: Re: [RFC 3/9] net: dsa: mv88e6xxx: add support for VTU ops
Date: Thu, 04 Jun 2015 11:22:49 -0700
Message-ID: <55709779.4040101@cumulusnetworks.com>
References: <1433208470-25338-1-git-send-email-vivien.didelot@savoirfairelinux.com> <1433208470-25338-4-git-send-email-vivien.didelot@savoirfairelinux.com> <556D522E.90607@roeck-us.net> <CAE4R7bChwW1awn8V6k7bF13v15_kPF0ui3NvyV2WkqN0XuTUqw@mail.gmail.com> <556E2EC2.3020104@cumulusnetworks.com> <CAE4R7bCEqszSew4RadLoB-PcY0g74F+sLKQL42TgsfG8_89_Kg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Guenter Roeck <linux@roeck-us.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, Jiri Pirko <jiri@resnulli.us>,
	Jerome Oufella <jerome.oufella@savoirfairelinux.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	kernel <kernel@savoirfairelinux.com>,
	Chris Healy <cphealy@gmail.com>,
	Wilson Kok <wkok@cumulusnetworks.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAE4R7bCEqszSew4RadLoB-PcY0g74F+sLKQL42TgsfG8_89_Kg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/02/2015 11:53 PM, Scott Feldman wrote:
> I'm talking about bridging tagged traffic.  E.g.:
>
> ip link add name br0 type bridge
> ip link add name br1 type bridge
>
> ip link set dev sw1p1 master br0
> ip link set dev sw1p2 master br0
> ip link set dev sw1p3 master br1
> ip link set dev sw1p4 master br1
>
> bridge vlan add vid 100 dev sw1p1
> bridge vlan add vid 100 dev sw1p2
> bridge vlan add vid 100 dev sw1p3
> bridge vlan add vid 100 dev sw1p4
>
> Now the ports are trunking vlan 100 and the bridge/device see tagged
> traffic.  If the device used floods vlan 100 pkt to all ports in vlan
> 100, it'll flood to a port outside the bridge.  Oops!  For the device
> I'm using (rocker w/ OF-DPA) the bridging table matches on vlan ID and
> mac_dst.  There is no prevision to isolate vlans per bridge.
>
> How do you solve the above case with your hardware?

Ah, understood, thanks for clarifying.

Right now, we only support this case with vconfig-style vlans.  I don't 
see any conceptual reason it couldn't be supported in the vlan-aware 
bridge model as well.  The HW configuration would be essentially 
identical to the equivalent vconfig-style config.
