From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6] net: vlan: make non-hw-accel rx path
 similar to hw-accel
Date: Sun, 3 Apr 2011 15:22:29 +0200
Message-ID: <20110403132228.GA2737@psychotron.redhat.com>
References: <1301739966-7604-1-git-send-email-jpirko@redhat.com>
 <20110402085524.6692131a@nehalam>
 <20110402182711.GA11885@psychotron.redhat.com>
 <4D983D81.2020500@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, davem@davemloft.net, kaber@trash.net,
	fubar@us.ibm.com, eric.dumazet@gmail.com, andy@greyhouse.net,
	xiaosuo@gmail.com, jesse@nicira.com
To: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20940 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752327Ab1DCNWt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Apr 2011 09:22:49 -0400
Content-Disposition: inline
In-Reply-To: <4D983D81.2020500@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Apr 03, 2011 at 11:27:29AM CEST, nicolas.2p.debian@gmail.com wrote=
:
>Le 02/04/2011 20:27, Jiri Pirko a =E9crit :
>>Sat, Apr 02, 2011 at 05:55:24PM CEST, shemminger@linux-foundation.org=
 wrote:
>>>On Sat,  2 Apr 2011 12:26:06 +0200
>>>Jiri Pirko<jpirko@redhat.com>  wrote:
><snip>
>>>>+	rawp =3D skb->data;
>>>>+	if (*(unsigned short *) rawp =3D=3D 0xFFFF)
>>>>+		/*
>>>>+		 * This is a magic hack to spot IPX packets. Older Novell
>>>>+		 * breaks the protocol design and runs IPX over 802.3 without
>>>>+		 * an 802.2 LLC layer. We look for FFFF which isn't a used
>>>>+		 * 802.2 SSAP/DSAP. This won't work for fault tolerant netware
>>>>+		 * but does for the rest.
>>>>+		 */
>>>>+		skb->protocol =3D htons(ETH_P_802_3);
>>>>+	else
>>>>+		/*
>>>>+		 * Real 802.2 LLC
>>>>+		 */
>>>>+		skb->protocol =3D htons(ETH_P_802_2);
>>>>+}
>>>
>>>What about doublely tagged packets?
>>
>>No problem. Once they are untagged and reinjected they are untagged
>>again and reinjected again:
>>
>>->  __netif_reveive_skb
>>vlan_untag
>>vlan_do_receive
>>->  __netif_receive_skb
>>vlan_untag
>>vlan_do_receive
>
>Hi Jiri,
>
>Instead of untagging and reinjecting, wouldn't it be possible to
>remove all 802.1Q headers in a loop and directly deliver the untagged
>skb? Are there any hw-accel implementations that remove several level
>of tagging?

Makes no sense to untag multiple tags in loop at once. For each tag you
need to call vlan_do_receive so the frame could be properly processed b=
y
vlan code.

I'm not aware of a possibility of hwaccel to untag multiple tags at
once. Honestly I cannot imagine how that could be handled (maybe settin=
g
array of vlan_tcis).

Jirka

>
>	Nicolas.
