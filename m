From: chetan loke <loke.chetan@gmail.com>
Subject: Re: [af-packet 1/2] Enhance af-packet to provide (near zero)lossless
 packet capture functionality.
Date: Wed, 8 Jun 2011 18:10:02 -0400
Message-ID: <BANLkTi=_EFRaiPuT=OjwRaJ4XPw0sUhcnA@mail.gmail.com>
References: <1307502786-1396-1-git-send-email-loke.chetan@gmail.com>
	<1307502786-1396-2-git-send-email-loke.chetan@gmail.com>
	<1307507754.3102.18.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, kaber@trash.net,
	johann.baudy@gnu-log.net, Chetan Loke <lokec@ccs.neu.edu>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f179.google.com ([209.85.212.179]:43082 "EHLO
	mail-px0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752169Ab1FHWKE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2011 18:10:04 -0400
Received: by pxi2 with SMTP id 2so623350pxi.10
        for <netdev@vger.kernel.org>; Wed, 08 Jun 2011 15:10:03 -0700 (PDT)
In-Reply-To: <1307507754.3102.18.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 8, 2011 at 12:35 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le mardi 07 juin 2011 =C3=A0 23:13 -0400, Chetan Loke a =C3=A9crit :
>>
>> +struct tpacket3_hdr {
>> + =C2=A0 =C2=A0 __u32 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 tp_status;
>> + =C2=A0 =C2=A0 __u32 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 tp_len;
>> + =C2=A0 =C2=A0 __u32 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 tp_snaplen;
>> + =C2=A0 =C2=A0 __u16 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 tp_mac;
>> + =C2=A0 =C2=A0 __u16 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 tp_net;
>
>> + =C2=A0 =C2=A0 __u32 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 tp_sec;
>> + =C2=A0 =C2=A0 __u32 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 tp_nsec;
>> + =C2=A0 =C2=A0 __u16 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 tp_vlan_tci=
;
>
> missing "__u16 tp_padding;" here
>
> check :
>
> http://git2.kernel.org/?p=3Dlinux/kernel/git/davem/net-2.6.git;a=3Dco=
mmit;h=3D13fcb7bd322164c67926ffe272846d4860196dc6


Eric, thanks for pointing that. I will add the padding. But just out
of curiosity, how is the information being leaked in tpacket_rcv()?

If someone is capturing packets then they have access to all the data
anyways. Also, tpacket_rcv doesn't memset the frame-element to 'zero'
before calling
skb_copy_bits(). And we would never want to memset anyways.

thnx
Chetan Loke
