From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [RFC 3/9] net: dsa: mv88e6xxx: add support for VTU ops
Date: Wed, 3 Jun 2015 10:56:18 -0400 (EDT)
Message-ID: <1116609866.252533.1433343378543.JavaMail.zimbra@savoirfairelinux.com>
References: <1433208470-25338-1-git-send-email-vivien.didelot@savoirfairelinux.com> <1433208470-25338-4-git-send-email-vivien.didelot@savoirfairelinux.com> <556D522E.90607@roeck-us.net> <1561034247.953427.1433295590494.JavaMail.zimbra@savoirfairelinux.com> <20150603021714.GA932@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, David <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	=?utf-8?Q?J=C3=A9rome?= Oufella
	<jerome.oufella@savoirfairelinux.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	kernel <kernel@savoirfairelinux.com>,
	Chris Healy <cphealy@gmail.com>
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150603021714.GA932@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Guenter,

On Jun 2, 2015, at 10:17 PM, Guenter Roeck linux@roeck-us.net wrote:
> On Tue, Jun 02, 2015 at 09:39:50PM -0400, Vivien Didelot wrote:
>> Guenter,
>> 
>> On Jun 2, 2015, at 2:50 AM, Guenter Roeck linux@roeck-us.net wrote:
>> > On 06/01/2015 06:27 PM, Vivien Didelot wrote:
>> >> +    /* Bringing an interface up adds it to the VLAN 0. Ignore this. */
>> >> +    if (!vid)
>> >> +        return 0;
>> >> +
>> > 
>> > Me puzzled ;-). I brought this and the fid question up before.
>> > No idea if my e-mail got lost or what happened.
>> > 
>> > Can you explain why we don't need a configuration for vlan 0 ?
>> 
>> Sorry for late reply. Initially, when issuing "ip link set up dev swp0",
>> ndo_vlan_rx_add_vid was called to add the interface in the VLAN 0.
>> 
> Loading the 802.1q module has the same effect.
> 
> I think this may be on purpose; it is telling the switch to accept
> packets with vid==0 (and untagged packets).
> 
>> 2 things happen here:
>> 
>>   * this is inconsistent with the "bridge vlan" output which doesn't seem to
>>     know about a VID 0;
>>   * VID 0 seems special for this switch: if an ingressing frame has VID 0, the
>>     tagged port will override the VID bits with the port default VID at egress.
>> 
> As far as I can see, the switch treats packets with vid==0 and untaged packets
> as unknown if VLAN support is enabled.

I am not sure about the untagged frames. But for tagged frames, the
documentation says that frames with vid 0 will be overridden with the port's
default VID.

> Anyway, sounds odd. Sure this isn't a configuration problem somethere ?

If I'm not mistaken, other drivers do that. e.g. Rocker deals with VID >= 1:

    for (vid = 1; vid < VLAN_N_VID; vid++)

Maybe this VID overriding feature is what we want? But it doesn't look right to
me, even more since it is not exposed to the user.

Thanks,
-v
