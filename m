From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH NEXT] rtlwifi: Fix endian error in extracting packet type
Date: Tue, 29 Oct 2013 15:27:41 +0100
Message-ID: <87y55cf8yq.fsf@nemi.mork.no>
References: <1383002903-8746-1-git-send-email-Larry.Finger@lwfinger.net>
	<1383005246.3779.61.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Larry Finger <Larry.Finger@lwfinger.net>, <linville@tuxdriver.com>,
	<linux-wireless@vger.kernel.org>,
	"Mark Cave-Ayland" <mark.cave-ayland@ilande.co.uk>,
	<netdev@vger.kernel.org>, Stable <stable@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1383005246.3779.61.camel@bwh-desktop.uk.level5networks.com> (Ben
	Hutchings's message of "Tue, 29 Oct 2013 00:07:26 +0000")
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Hutchings <bhutchings@solarflare.com> writes:

>> @@ -1077,8 +1077,8 @@ u8 rtl_is_special_data(struct ieee80211_hw *hw=
, struct sk_buff *skb, u8 is_tx)
>> =20
>>  	ip =3D (struct iphdr *)((u8 *) skb->data + mac_hdr_len +
>>  			      SNAP_SIZE + PROTOC_TYPE_SIZE);
>> -	ether_type =3D *(u16 *) ((u8 *) skb->data + mac_hdr_len + SNAP_SIZ=
E);
>> -	/*	ether_type =3D ntohs(ether_type); */
>> +	ether_type =3D be16_to_cpu(*(__be16 *)((u8 *)skb->data + mac_hdr_l=
en +
>> +					     SNAP_SIZE));
>> =20
>>  	if (ETH_P_IP =3D=3D ether_type) {
>>  		if (IPPROTO_UDP =3D=3D ip->protocol) {
>
> This crazy function also says that *all* IPv6 frames are special, whi=
ch
> apparently means that on TX they should get sent at the lowest possib=
le
> bit rate.  So I think this is going to cause a regression for IPv6
> throughput unless you remove that case.
>
> The DHCP case is also not validating IP and UDP header lengths agains=
t
> the packet length, though this may be harmless in practice.

It's not validating the upper 8 bits of the port numbers either, so it
will hit random UDP traffic in addition to DHCP.=20

But it was good to see this function now. I was wondering how to suppor=
t
some buggy 3G modem firmware without ugly hacks. Seems there will alway=
s
be worse hacks in drivers/net, no matter what I do :-)


Bj=C3=B8rn
