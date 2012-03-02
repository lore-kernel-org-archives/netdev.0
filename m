From: Syed Muhammad Mohsin Kazmi <08beesmmkazmi@seecs.edu.pk>
Subject: Re: data is truncated in skb
Date: Fri, 2 Mar 2012 16:25:25 +0500
Message-ID: <CAAZheX=R-MVoa1Cgs8+=zON6ZC7Van8tH-GermuCTK1PEK-9ew@mail.gmail.com>
References: <CAAZheX=A9=iuSDS+w4u_kqn4QvffdboKngopJgTegrsOUHQrHg@mail.gmail.com>
	<CAAZheXmgb=Se6YJdp=LpH0G1vco1oms2XARtXs3HTf3DKZtrRA@mail.gmail.com>
	<20120301200726.6b0d845c@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:36262 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964797Ab2CBLZ0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2012 06:25:26 -0500
Received: by vbbff1 with SMTP id ff1so1366067vbb.19
        for <netdev@vger.kernel.org>; Fri, 02 Mar 2012 03:25:25 -0800 (PST)
In-Reply-To: <20120301200726.6b0d845c@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

here is the code of encapsulation...!

struct sk_buff *create_trill_header(struct sk_buff *skb,bool
trill_header_ok,size_t msglen)
{

	unsigned int extra_header_length;
	uint16_t ether_type;
	struct trill_header *push1;
	struct ethhdr *push2;
	struct ethhdr *push3;

	ether_type =3D msglen > 0 ? (uint16_t)msglen : ETHERTYPE_TRILL;

	extra_header_length =3D trill_header_ok ? 0 : sizeof (struct trill_hea=
der);

	struct ethhdr *mac_header =3D eth_hdr(skb);

	if (mac_header =3D=3D NULL)
	{
		// error handling
		printk("mac_header Error\n");
	}
=09
	printk("\t\t\tOriginal Buffer\n");
=09
	trill_testing(skb);

	if ( skb_headroom(skb) < 2*sizeof(struct ethhdr ) + sizeof(struct
trill_header) )
	{
		skb =3D skb_realloc_headroom(skb,34);
		printk("\t\t\tHEADROOM ALLOCATION\n");
	}
=09
	push2 =3D (struct ethhdr *)skb_push(skb,ETH_HLEN);
=09
	memcpy(push2->h_dest,mac_header->h_dest,ETH_ALEN);
=09
	memcpy(push2->h_source,mac_header->h_source,ETH_ALEN);
=09
	push2->h_proto =3D htons(0x0800); // ether_type IP
=09
	push1 =3D (struct trill_header *)skb_push(skb,extra_header_length);
=09
	push1->th_version =3D  TRILL_PROTOCOL_VERSION;
=09
	push1->th_reserved =3D TRILL_RESERVED_BITS;
=09
	push1->th_multidest =3D  TRILL_UNICAST;
=09
	push1->th_optslen_hi =3D 0;

	push1->th_optslen_lo =3D 0;
=09
	push1->th_hopcount =3D DEFAULT_HOPCOUNT;
=09
	push1->th_egressnick =3D htons(0x1600);
=09
	push1->th_ingressnick =3D htons(0x1500);
=09
	push3 =3D (struct ethhdr *)skb_push(skb,ETH_HLEN);
=09
	memcpy(push3->h_dest,mac_header->h_dest,ETH_ALEN);
=09
	memcpy(push3->h_source,mac_header->h_source,ETH_ALEN);
=09
	push3->h_proto =3D htons(ether_type); // ether_type Trill
=09
	if(skb->data =3D=3D push3)
	{
		skb_set_mac_header(skb,0);
=09
		skb_pull(skb,ETH_HLEN);
=09
		mac_header =3D eth_hdr(skb);
=09
	}
=09
	printk("\t\t\tencapsulated Buffer\n");
=09
	trill_testing(skb);
=09
	return skb;
=09
}

On Fri, Mar 2, 2012 at 9:07 AM, Stephen Hemminger <shemminger@vyatta.co=
m> wrote:
> On Fri, 2 Mar 2012 07:17:16 +0500
> Syed Muhammad Mohsin Kazmi <08beesmmkazmi@seecs.edu.pk> wrote:
>
>> hi,
>> =A0 I have written a code which encapsulates the packets GOINGOUT or
>> OTHERHOST in bridging module. Encapsulation is done fine. But data a=
t
>> the end of buffer is truncated by the size of encapsulation. What
>> should i do to avoid truncation of data?
>
>
> No idea. Post question and code to netdev list
