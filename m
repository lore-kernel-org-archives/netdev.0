From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [RFC PATCH] net/core: fix skb handling on netif serves for both
 bridge and vlan
Date: Sat, 5 Mar 2011 15:25:32 +0100
Message-ID: <20110305142530.GA8573@psychotron.redhat.com>
References: <1299149713-18740-1-git-send-email-dfeng@redhat.com>
 <20110305103613.GB7799@psychotron.redhat.com>
 <4D72406B.6090504@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Xiaotian Feng <dfeng@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>
To: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4D72406B.6090504@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sat, Mar 05, 2011 at 02:53:47PM CET, nicolas.2p.debian@gmail.com wrote:
>Le 05/03/2011 11:36, Jiri Pirko a =E9crit :
>>Thu, Mar 03, 2011 at 11:55:13AM CET, dfeng@redhat.com wrote:
>>>Consider network topology as follows:
>>>
>>>eth0  eth1
>>>|_____|
>>>    |
>>>  bond0 --- br0
>>>    |
>>>  vlan0 --- br1
>>>
>>>bond0 serves for both br0 and vlan0, if a vlan tagged packet was sen=
t
>>>to br1 through bond0, bridge handling code is seeing the packet on b=
ond0
>>>and handing it off to my "legacy" bridge before vlan_tx_tag_present
>>>and vlan_hwaccel_do_receive even haven't a chance to look at it.
>>>
>>>Moving the vlan_tx_tag_present before bridge/macvlan handling code c=
ould
>>>cure this.
>>
>>Wouldn't this break "eth0 - br0 - br0.5"?
>
>I think it would. One more reason to build a single interface stacking=
 framework...

I plan to deal with vlans later. This kind of topology would not be
possible after that :)
>
>	Nicolas.
