From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [RFC 8/9] net: dsa: mv88e6352: set port 802.1Q mode to Secure
Date: Tue, 2 Jun 2015 19:45:12 -0400 (EDT)
Message-ID: <866754493.893733.1433288712367.JavaMail.zimbra@savoirfairelinux.com>
References: <1433208470-25338-1-git-send-email-vivien.didelot@savoirfairelinux.com> <1433208470-25338-9-git-send-email-vivien.didelot@savoirfairelinux.com> <556DBE5D.9000003@roeck-us.net>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([209.172.62.77]:52882 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751564AbbFBXpP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 19:45:15 -0400
In-Reply-To: <556DBE5D.9000003@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Guenter,

On Jun 2, 2015, at 10:31 AM, Guenter Roeck linux@roeck-us.net wrote:
On 06/01/2015 06:27 PM, Vivien Didelot wrote:
>> This commit changes the 802.1Q mode of each port from Disabled to
>> Secure. This enables the VLAN support, by checking the VTU entries on
>> ingress.
>>
>> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
>> ---
>>   drivers/net/dsa/mv88e6xxx.c | 14 +++++++-------
>>   drivers/net/dsa/mv88e6xxx.h |  5 +++++
>>   2 files changed, 12 insertions(+), 7 deletions(-)
>>
>> diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
>> index ed49bd8..35243d8 100644
>> --- a/drivers/net/dsa/mv88e6xxx.c
>> +++ b/drivers/net/dsa/mv88e6xxx.c
>> @@ -1723,13 +1723,11 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds,
>> int port)
>>              goto abort;
>>      }
>>
>> -    /* Port Control 2: don't force a good FCS, set the maximum
>> -     * frame size to 10240 bytes, don't let the switch add or
>> -     * strip 802.1q tags, don't discard tagged or untagged frames
>> -     * on this port, do a destination address lookup on all
>> -     * received packets as usual, disable ARP mirroring and don't
>> -     * send a copy of all transmitted/received frames on this port
>> -     * to the CPU.
>> +    /* Port Control 2: don't force a good FCS, set the maximum frame size to
>> +     * 10240 bytes, enable secure 802.1q tags, don't discard tagged or
>> +     * untagged frames on this port, do a destination address lookup on all
>> +     * received packets as usual, disable ARP mirroring and don't send a
>> +     * copy of all transmitted/received frames on this port to the CPU.
>>       */
>>      reg = 0;
>>      if (mv88e6xxx_6352_family(ds) || mv88e6xxx_6351_family(ds) ||
>> @@ -1751,6 +1749,8 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int
>> port)
>>              reg |= PORT_CONTROL_2_FORWARD_UNKNOWN;
>>      }
>>
>> +    reg |= PORT_CONTROL_2_8021Q_SECURE;
>> +
> 
> Hi Vivien,
> 
> Unless I misunderstand the documentation, this effectively disables VLAN
> support on non-bridge ports, especially since the ndo_ functions to add VLAN
> entries to such ports are not implemented. Is that intentional, or am I
> missing something ?

Indeed, I intentionaly set the port mode to Secure to work on 802.1q.
For both cases, the Fallback mode should be enough; this mode checks the
VTU for a valid entry, otherwise checks the port-based VLAN map.

Supporting port-based VLAN looks like another tricky thread.

Ideally, this must be configurable. In my case I do need strict 802.1q.
Can ethtool/iproute2 can do something about the port 802.1q mode?

Thanks,
-v
