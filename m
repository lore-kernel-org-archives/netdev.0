From: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [RFC PATCH] net/core: fix skb handling on netif serves for both
 bridge and vlan
Date: Thu, 03 Mar 2011 22:42:24 +0100
Message-ID: <4D700B40.9010209@gmail.com>
References: <1299149713-18740-1-git-send-email-dfeng@redhat.com> <1299160414.4277.49.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Xiaotian Feng <dfeng@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>,
	Jiri Pirko <jpirko@redhat.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1299160414.4277.49.camel@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 03/03/2011 14:53, Ben Hutchings a =C3=A9crit :
> On Thu, 2011-03-03 at 18:55 +0800, Xiaotian Feng wrote:
>> Consider network topology as follows:
>>
>> eth0  eth1
>>   |_____|
>>      |
>>    bond0 --- br0
>>      |
>>    vlan0 --- br1
>>
>> bond0 serves for both br0 and vlan0, if a vlan tagged packet was sen=
t
>> to br1 through bond0, bridge handling code is seeing the packet on b=
ond0
>> and handing it off to my "legacy" bridge before vlan_tx_tag_present
>> and vlan_hwaccel_do_receive even haven't a chance to look at it.
> [...]
>
> This used to work if the underlying device (bond0 in your example)
> implemented VLAN tag extraction, because the VLAN group would be chec=
ked
> before the bridge.  But it never worked for devices without VLAN tag
> extraction.  Perhaps we should just prevent this configuration.

If Jiri Pirko eventually move vlan processing to rx_handler, then the s=
etup won't be possible,=20
because bond0 would require two rx_handlers : one for bridge (-> br0) a=
nd one for vlan (-> vlan0).

Or we need several rx_handlers per net_device, if the above setup is a =
real one.

	Nicolas.
