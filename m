From: Yegor Yefremov <yegorslists@googlemail.com>
Subject: Re: KS8695: possible NAPI issue
Date: Mon, 8 Mar 2010 15:10:08 +0100
Message-ID: <f69abfc31003080610m2701309ekd1a4a38ac2685703@mail.gmail.com>
References: <f69abfc31003020404y7af77fe5icefeee4644c7d08e@mail.gmail.com>
	 <4B8D1C02.1010204@softplc.com>
	 <c6ed1ac51003021746n2b246591g880b584550ec5e84@mail.gmail.com>
	 <f69abfc31003040210i7e8a136am4b4a97306ba770cf@mail.gmail.com>
	 <c6ed1ac51003042254g27f65f9dhd9bd731e05a9518@mail.gmail.com>
	 <f69abfc31003050206h4f9ffe65s2b90e6acea014ec2@mail.gmail.com>
	 <1267798077.2576.17.camel@myhost>
	 <f69abfc31003050700y57718a6aje3c1ff41d04748ae@mail.gmail.com>
	 <c6ed1ac51003080104l4d67d72aybd3909ac12b54e3b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dick Hollenbeck <dick@softplc.com>, netdev@vger.kernel.org,
	zealcook@gmail.com
To: figo zhang <figo1802@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f216.google.com ([209.85.219.216]:38215 "EHLO
	mail-ew0-f216.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754468Ab0CHOKK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Mar 2010 09:10:10 -0500
Received: by ewy8 with SMTP id 8so73046ewy.28
        for <netdev@vger.kernel.org>; Mon, 08 Mar 2010 06:10:08 -0800 (PST)
In-Reply-To: <c6ed1ac51003080104l4d67d72aybd3909ac12b54e3b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 8, 2010 at 10:04 AM, figo zhang <figo1802@gmail.com> wrote:
> 2010/3/5 Yegor Yefremov <yegorslists@googlemail.com>:
>>>> My tests look like following:
>>>>
>>>> 1. system start
>>>> 2. ping one host: O.K.
>>>> 3. nc -l -p 5000 > /var/test (about 1Mb): O.K.
>>>> 4. ping the same host: failed
>>> 1. type "arp" command, see the arp is exit or expire?
>>
>> debian:~# nc -l -p 5000 > /var/zImage
>>
>> debian:~# ping -c 1 192.168.1.38
>>
>> PING 192.168.1.38 (192.168.1.38) 56(84) bytes of data.
>>
>> From 192.168.1.66 icmp_seq=3D1 Destination Host Unreachable
>>
>>
>>
>> --- 192.168.1.38 ping statistics ---
>>
>> 1 packets transmitted, 0 received, +1 errors, 100% packet loss, time=
 0ms
>>
>>
>>
>> debian:~# arp
>>
>> Address =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
HWtype =C2=A0HWaddress =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Flags Mask =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Iface
>> 192.168.1.38 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0(incomplete) =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0eth0
>>
>> 192.168.1.36 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ether =C2=A0 =
00:10:18:39:19:aa =C2=A0 C =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 eth0
>>
>>
>>> 2. at this point, see is it still have RX interrpt and receive pack=
et in
>>> ks8695_rx()? (in some watchpoint add printk).
>>
>> I've inserted some printks and I can see that interrupts are coming
>> and the received count will be increased. I can also see my system
>> sending arp requests. Even this ping request is visible in wireshark
>> and its reply, but the ping utility sees nothing of it.
>>
>
> when you netcat finished, it cannot ping, right? at this point, would
> you like to add some printk at RX and TX?
> i want to see the target board have send arp packet, or have receive
> arp reply packet.
>
> you can add such funtion to print the packet buffer:
>
> void print_mem(unsigned char *p,u32 len, u8 * s)
> {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u32 i;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0printk(" =C2=A0%s =C2=A0 ram addr =3D %x ,=
 data len =3D %x",s, p, len);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0for (i=3D0;i<len;i++) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (0=3D=3Di%1=
6) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0printk("\n =C2=A00x%02x : ",(p+i));
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0printk("%02x",=
*(u8 *)(p+i));
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0printk(" ");
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0printk("\n\n");
> }
>
> for TX: ks8695_start_xmit(struct sk_buff *skb, struct net_device *nde=
v)
>
> =3D>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0ksp->tx_ring[buff_n].status =3D
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0cpu_to_le32(TD=
ES_IC | TDES_FS | TDES_LS |
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0(skb->len & TDES_TBS));
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0print_mem(skb->data, skb->len, "tx");
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0wmb();
>
> for RX: static int ks8695_rx(struct ks8695_priv *ksp, int budget)
> =3D>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0/* Retrieve the sk_buff */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0skb =3D ksp->rx_buffers[buff_n].skb;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0print_mem(skb->data, skb->len, "rx");
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0/* Clear it from the ring */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0ksp->rx_buffers[buff_n].skb =3D NULL;
>

skb->len in RX is always 0, so I took pktlen.

This is the end of the netcat transmission (the transfer stocked at
about 10% of file size):

  rx   ram addr =3D c288d020 , data len =3D 5ea

  dst:00:04:d9:80:94:cd src:00:18:f3:fe:84:84 type: 0x0800

  0xc288d02c : 45 00

  0xc288d030 : 05 dc 1a 4e 40 00 80 06 57 15 c0 a8 01 26 c0 a8

  0xc288d040 : 01 42 07 7d 13 88 db 12 9b 31 fe 7e 93 ae 50 10

  0xc288d050 : ff ff 60 69 00 00 d2 7c ed 11 b2 c9 3b 9a 6f 72

  0xc288d060 : 33 8d 3d f8 aa 97 30 3a 4b bc 19 93 39 e9 a2 e3

  0xc288d070 : d7 9a 28 d2 7e 48 f6 be a4 79 3a c3 31 13 2c 4d

  0xc288d080 : 0f 1b 6f 39 5d aa 6f c2 cd 81 29 88 2a 86 d2 56

  0xc288d090 : d0 7c 19 33 c1 5e 45 20 b9 ba dd 2a 7b f3 65 18

  0xc288d0a0 : 86 61 62 a4 a3 f9 de a8 93 8f 37 78 ec 87 b5 19

  0xc288d0b0 : 90 66 a2 a8 53 9c fd f7 75 67 89 34 85 1e 33 de

  0xc288d0c0 : 7e 10 b3 c4 7b 4c 62 cc 04 13 c5 fe 14 dc 44 7b

  0xc288d0d0 : 23 cd 62 0a d4 32 51 c5 50 da 0a 9a 2f 63 26 d8

  0xc288d0e0 : ab 08 24 57 b7 5b 65 6f be 81 ef 02 b9 98 0c 6e

  0xc288d0f0 : 60 06 4b 30 85 bb 9f ff dc fc c3 6c 6e 7d 7b 6e

  0xc288d100 : 43 e0 26 47 7b 20 7a 06 f1 29 ce bb 71 8a dd ee

  0xc288d110 : c6 1e f9 34 7e 1a 27 4d 7f bb d2 cf 72 dd 19 d3

  0xc288d120 : f8 4e 37 ed a4 f1 96 13 f5 31 a5 7f 3a c9 96 13

  0xc288d130 : 69 8a 2e d5 1e b0 06 8a a0 a8 62 28 6d 05 cd 97

  0xc288d140 : 31 13 ec 55 04 92 ab db ad 52 99 ef f1 78 6c 9a

  0xc288d150 : 66 b7 db d5 75 fd f2 db 1f 2e 9f 4f cf ee a0 e7

  0xc288d160 : 5d 20 17 93 c1 0d cc 60 09 a6 68 69 be f6 08 dc

  0xc288d170 : e4 68 0f 44 cf 20 3e c5 79 77 4d 09 24 2b e5 0d

  0xc288d180 : 8c 3d d7 6d 9d 34 cd 2c f1 dc ea ea 83 9f 1d 79

  0xc288d190 : a5 42 9a 66 22 cf a3 89 ba 07 ae 3e be 7f cc bc

  0xc288d1a0 : 3f e0 dd 57 11 14 55 0c a5 ad a0 f9 32 66 82 bd

  0xc288d1b0 : 8a 40 72 75 bb 55 7e 37 5f 67 b8 db ed b6 aa aa

  0xc288d1c0 : ba e7 a5 37 5f c4 fd 34 f5 2e 18 67 d3 73 eb ab

  0xc288d1d0 : 18 67 15 37 d0 4f 06 4b 30 45 4b f3 b5 47 e0 26

  0xc288d1e0 : 47 7b 20 7a 06 f1 29 36 fb 8d ba 0a b1 25 2b f1

  0xc288d1f0 : dd 8b 3d dd 6d 9d 34 cd 2c f1 ac 27 ea d3 19 1d

  0xc288d200 : 7c 8d 42 9a 66 22 bf 8d 5e 71 39 b7 d5 de 48 d3

  0xc288d210 : 99 02 45 50 54 31 94 b6 82 e6 cb 98 09 f6 2a 02

  0xc288d220 : c9 d5 ed 56 39 30 5f 68 af 13 de fd 7e 7f e8 79

  0xc288d230 : 7f 78 44 9c f9 ba b8 13 46 df 85 13 9b 01 17 bc

  0xc288d240 : 59 97 fd b9 ff 4f 42 3e 47 62 58 cf bf 2f 5e 75

  0xc288d250 : 9b 4a 1b f5 15 9e bd 6f 33 cf 4f b6 84 3b a1 a5

  0xc288d260 : f9 da 23 70 93 a3 3d 10 3d 83 f8 14 67 df 38 85

  0xc288d270 : 94 86 f9 83 c7 9b 42 4c 97 60 8a 04 6b 89 3d cb

  0xc288d280 : d2 ba 73 95 59 e2 6d 86 a9 31 63 cf 12 e9 31 25

  0xc288d290 : 98 68 f4 59 44 7d 34 a7 91 63 6c 03 cf 98 57 7f

  0xc288d2a0 : 3a d6 40 11 14 55 0c a5 ad a0 f9 32 66 82 bd 8a

  0xc288d2b0 : 40 72 75 bb 55 0e cc b7 69 9a aa aa 9c f6 be be

  0xc288d2c0 : be be f5 fc fa f1 13 79 7f 78 74 e6 fb f9 f4 3c

  0xc288d2d0 : fa 2e 80 f0 17 7f 33 a1 96 8b fe 70 fe 4f 73 86

  0xc288d2e0 : 9d ba a4 e1 37 fc e2 f1 bb 54 da a8 af dc 7f ab

  0xc288d2f0 : 17 9d 9f 66 09 f7 43 4b f3 b5 47 e0 26 47 7b 20

  0xc288d300 : 7a 06 f1 29 ce be 71 22 84 10 b2 52 50 04 45 15

  0xc288d310 : 43 69 2b 68 be 8c 99 60 af 22 90 5c dd 6e 95 03

  0xc288d320 : f3 dd ed 76 75 5d 1f 0e 07 e7 bc 1f 3d 4e 75 5d

  0xc288d330 : 4e e6 eb 32 fa 2e 74 d3 02 b8 f9 62 ea c8 50 ac

  0xc288d340 : a6 d4 52 9f af cf 11 27 7b fe 7c 8e cf 4e 0d 2e

  0xc288d350 : 7e 0d 6f 56 db 24 da b8 c8 64 97 9e 9f 66 09 4b

  0xc288d360 : 19 3e 68 ff 0e b4 46 4b f3 b5 47 e0 26 47 7b 20

  0xc288d370 : 7a 06 f1 29 36 bb 21 09 21 84 dc 39 28 82 a2 8a

  0xc288d380 : a1 b4 15 34 5f c6 4c b0 57 11 48 ae 6e b7 ca 81

  0xc288d390 : f9 d6 3d 27 f3 3d 1e 8f 7f 57 7f 85 98 ef 1c bd

  0xc288d3a0 : 1a d5 d2 39 9e eb b7 54 ff 69 fe 3f 99 3f 66 78

  0xc288d3b0 : b3 da 26 d1 c6 45 26 bb f4 fc 34 4b 58 8a 7e 46

  0xc288d3c0 : 7a 21 36 69 69 be f6 08 dc e4 68 0f 44 cf 20 3e

  0xc288d3d0 : c5 f6 77 26 21 84 90 fb 04 45 50 54 31 94 b6 82

  0xc288d3e0 : e6 cb 98 09 f6 2a 02 c9 d5 ed 56 39 30 5f b8 ad

  0xc288d3f0 : 93 5c a7 ba 4e 78 9d f6 1e 8f c7 8f 8f 8f b7 b7

  0xc288d400 : b7 c3 e1 50 d7 f5 6e b7 1b 7d 17 ba ef 7e 71 52

  0xc288d410 : d7 cd 77 c4 09 73 cc f4 ac 96 ea d9 2f 1b 41 33

  0xc288d420 : 67 cc d1 55 2f a2 4d a5 8d 67 1f 84 ff 7c cf ad

  0xc288d430 : 4b b6 84 45 8c 3e a3 ee 6b 5d 37 bb ac 19 b4 34

  0xc288d440 : 5f 7b 04 6e 72 b4 07 a2 67 10 9f 62 e3 db 92 10

  0xc288d450 : 42 c8 dd 82 22 28 aa 18 4a 5b 41 f3 65 cc 04 7b

  0xc288d460 : 15 81 e4 ea 76 ab 9c 36 5f 97 8f 9e 45 e6 3b fc

  0xc288d470 : af ee e5 96 9a e9 4c 6f 9d 63 a9 fe 11 f4 75 0a

  0xc288d480 : 46 c7 9c ba 8c f9 b4 c9 b5 d1 ff 50 a6 ce f7 dc

  0xc288d490 : ba f4 4b 98 83 7e 46 62 09 66 45 a3 a5 f9 da 23

  0xc288d4a0 : 70 93 a3 3d 10 3d 83 f8 14 9b dd 90 84 10 42 3c

  0xc288d4b0 : 88 46 71 e6 4f eb 02 45 50 54 31 94 b6 82 e6 cb

  0xc288d4c0 : 98 09 f6 2a 02 c9 d5 ed 56 39 30 5f a7 ba 30 df

  0xc288d4d0 : 7f ff fe e7 af 1f 3f 5d de 7a 5e 5f 5f f7 fb 7d

  0xc288d4e0 : 55 55 4d d3 8c be 0b 60 8e 75 2e 35 d3 d1 5f cf

  0xc288d4f0 : fe 34 7f fc 39 07 3d 83 f8 7f 9a 43 9b 56 1b fd

  0xc288d500 : da eb f9 d5 73 5a e2 25 cc 44 5f b9 e7 c1 99 a2

  0xc288d510 : a5 f9 da 23 70 93 a3 3d 10 3d 83 f8 14 9b dd 90

  0xc288d520 : 84 10 42 3c 9c fd 7a 67 f0 79 47 11 14 55 0c a5

  0xc288d530 : ad a0 f9 32 66 82 bd 8a 40 72 75 bb 55 0e cc f7

  0xc288d540 : 78 3c 3a f3 75 79 7f 78 44 0e 3d 4e 7b eb ba de

  0xc288d550 : 6e b7 ee 84 d1 77 e1 c4 66 80 38 32 75 8e e7 a7

  0xc288d560 : d1 11 46 dd 76 6a b4 6e cc 77 f4 f8 fa df 8b f4

  0xc288d570 : 76 f4 b2 67 d2 a6 d2 46 7d 79 a3 47 ce 9e af d7

  0xc288d580 : 98 6c 09 8b d0 8f 52 ef 16 9b b4 34 5f 7b 04 6e

  0xc288d590 : 72 b4 07 a2 67 10 9f 62 cb 7b 92 10 42 c8 14 67

  0xc288d5a0 : bf de 19 7c de 51 04 45 15 43 69 2b 68 be 8c 99

  0xc288d5b0 : 60 af 22 90 5c dd 6e 95 03 f3 75 38 b7 75 e6 7b

  0xc288d5c0 : 4a dd 53 55 d5 a8 f6 76 56 ad 67 45 64 70 03 33

  0xc288d5d0 : 58 82 29 5a 9a af 3d 02 37 39 da 03 d1 33 88 4f

  0xc288d5e0 : 71 06 ad 11 21 84 dc 21 e2 eb bd f9 62 ea 84 35

  0xc288d5f0 : 82 22 28 aa 18 4a 5b 41 f3 65 cc 04 7b 15 81 e4

  0xc288d600 : ea 76 ab fc 6e be 0e 67 b8 9f



  rx   ram addr =3D c2853020 , data len =3D 3c

  dst:ff:ff:ff:ff:ff:ff src:00:18:f3:fe:84:84 type: 0x0806

  0xc285302c : 00 01

  0xc2853030 : 08 00 06 04 00 01 00 18 f3 fe 84 84 c0 a8 01 26

  0xc2853040 : 00 00 00 00 00 00 c0 a8 01 03 00 00 00 00 00 00

  0xc2853050 : 00 00 00 00 00 00 00 00 00 00 00 00



  rx   ram addr =3D c2846020 , data len =3D 5ea

  dst:00:04:d9:80:94:cd src:00:18:f3:fe:84:84 type: 0x0800

  0xc284602c : 45 00

  0xc2846030 : 05 dc 1a 51 40 00 80 06 57 12 c0 a8 01 26 c0 a8

  0xc2846040 : 01 42 07 7d 13 88 db 12 b7 b5 fe 7e 93 ae 50 10

  0xc2846050 : ff ff b6 b5 00 00 6d 2a f5 af 3a 5b 3e 26 ff 05

  0xc2846060 : c3 6a 7e 9d 42 c6 aa 25 05 46 01 8b c1 c9 c0 ce

  0xc2846070 : 52 f9 12 42 08 e9 4d 9c fe b0 df 46 d3 d2 20 4d

  0xc2846080 : d1 5b 91 1b 70 64 56 12 a9 54 cc a9 ea 0e 75 79

  0xc2846090 : 03 81 30 87 5e 38 24 4e 65 53 cd 93 82 34 bf a5

  0xc28460a0 : 9e cb 19 c0 df 24 44 ab fd 71 b9 cc e4 ad c3 55

  0xc28460b0 : e7 40 c6 4a 2e 72 63 70 06 02 8b c1 c9 c0 ce 52

  0xc28460c0 : f9 12 42 08 e9 4d 9c fe b0 df 46 d3 d2 20 4d d1

  0xc28460d0 : 5b 91 1b 70 64 56 12 a9 54 cc 69 54 31 49 13 08

  0xc28460e0 : 52 44 cc 4d 9c ca 86 ed 94 fa d4 28 ee 6a d2 b5

  0xc28460f0 : f8 d0 72 98 ba 0c 8c 06 14 6f c1 26 9d 45 c6 4a

  0xc2846100 : 5d c6 57 bd 2e 08 aa d7 b3 e6 29 4e 07 2a 5f 42

  0xc2846110 : 08 21 bd 89 d3 1f f6 db 68 5a 5a 88 19 bb 0f f2

  0xc2846120 : 0c 1c 99 95 44 2a 15 73 d6 56 32 1e 09 34 ce c4

  0xc2846130 : c4 a9 6c d8 4e 2c e8 c0 c7 52 3f ab 5d 2a 82 55

  0xc2846140 : 61 5f 3c 85 40 6b 5c 5a aa 06 2c ce 2f 7c 5d 10

  0xc2846150 : 0e 57 c8 4c 60 67 a9 7c 09 21 84 f4 26 4e 7f d8

  0xc2846160 : 6f a3 69 69 90 a6 e8 ad c8 0d 38 32 2b 89 54 2a

  0xc2846170 : e6 3c 94 27 f2 24 1d 89 97 59 89 53 d9 b0 9d 46

  0xc2846180 : 7d 6a 5c 0c 76 a9 08 56 c5 a9 c5 73 a1 14 95 b1

  0xc2846190 : b2 bb 33 2e 87 2b 64 26 b0 b3 54 be 84 10 42 7a

  0xc28461a0 : 13 a7 3f ec b7 d1 b4 34 48 53 f4 56 e4 06 1c 99

  0xc28461b0 : 95 44 2a e5 13 6e 6f e0 2b e0 ae 1c 33 31 71 2a

  0xc28461c0 : 9b b4 6d cb 28 2e d6 06 a8 df 51 fd c4 ea b3 60

  0xc28461d0 : 66 39 bf f1 1c 4f e2 00 c7 0a bf 7a 5c b0 18 9c

  0xc28461e0 : 0c ec ac a6 7c ff b3 1f 3f 76 e5 fb f5 cf fd f8

  0xc28461f0 : f2 f2 af 4f bf 7d a3 f2 25 84 10 e2 26 4e 7f d8

  0xc2846200 : 6f a3 69 e9 91 66 69 af c8 b3 71 64 56 12 a9 d4

  0xc2846210 : c3 b0 69 24 03 26 4e 65 bb 37 0e 46 2c ab e2 70

  0xc2846220 : 4c e3 d2 1a 25 56 d7 b2 94 d7 d8 59 2a 5f 42 08

  0xc2846230 : 21 bd 89 d3 1f f6 db 68 5a fa b1 35 54 02 b9 1e

  0xc2846240 : 47 66 25 91 4a 3d 0c eb 34 6d 34 e2 54 b6 7b e3

  0xc2846250 : 60 64 7b 03 8f 69 79 fc 90 51 62 75 2d 4b 79 8d

  0xc2846260 : 9d 9d 58 f9 6e 19 c5 45 e3 b0 45 ea f6 93 b1 47

  0xc2846270 : 95 f1 27 64 1a e2 f4 87 d7 6e 34 39 2d 25 8b d5

  0xc2846280 : 8e f8 70 64 56 12 a9 d4 c3 b0 45 76 f0 38 95 8d

  0xc2846290 : 07 0f 1e 96 63 38 e5 bb d7 84 77 7f 83 8b 6a 21

  0xc28462a0 : 63 6b b7 8a 2b e0 29 d2 0f 86 9a 90 e9 89 d3 1f

  0xc28462b0 : 5a 36 1a 1f 2d a5 8c 55 90 f8 70 64 56 12 a9 d4

  0xc28462c0 : c3 b0 45 76 f6 38 95 ed de 38 0c c4 9a b1 5a ca

  0xc28462d0 : 6b ec ec 70 ca f7 55 f3 ee ec 27 60 58 ad e4 be

  0xc28462e0 : 5e 2f ee 3e fe e6 d7 17 29 da 76 5e c3 9e 9f 14

  0xc28462f0 : b7 6a 17 f3 f0 e2 61 78 a4 bc 0e 4c 22 84 84 22

  0xc2846300 : 4e 7f 68 d9 68 7c b4 54 21 16 30 e2 c3 91 59 49

  0xc2846310 : a4 52 0f c3 16 d9 94 e3 54 b6 7b e3 30 10 6b c6

  0xc2846320 : 6a 29 af b1 b3 54 be f9 df fc fa 22 45 fb 14 85

  0xc2846330 : ea 2c 4e 0e 2f aa 7f d5 2b 87 0f e6 2f 52 5f 4a

  0xc2846340 : 08 09 45 9c fe d0 b2 d1 f8 68 29 41 ac 5e c4 87

  0xc2846350 : 23 b3 92 48 a5 1e 86 2d b2 23 c7 a9 6c 2d 5e 3c

  0xc2846360 : ed 63 6d 6f b4 cf e3 9e 6d 29 0d f8 60 29 af b1

  0xc2846370 : b3 c3 29 df 57 cd bb 83 97 3a 16 53 52 52 c9 dc

  0xc2846380 : 59 a4 68 9f e2 94 c8 ad 55 24 cb 15 f5 fa a9 b7

  0xc2846390 : 13 42 42 11 a7 3f b4 6c 34 3e 5a 4a 10 ab 17 f1

  0xc28463a0 : e1 c8 ac 24 52 a9 87 61 8b ec c8 71 2a 9b 6a de

  0xc28463b0 : 96 91 cc ed 16 98 01 0c b3 84 cb de b3 d9 ef 9e

  0xc28463c0 : 5d 69 20 56 87 17 8b 38 58 22 13 04 2c 06 27 03

  0xc28463d0 : 3b 3b 9c f2 35 52 5b c0 6a 0a e3 d5 3e c4 92 7e

  0xc28463e0 : 0e 3e ed 09 04 2c 78 0a 3f 68 7f 3b 21 24 02 71

  0xc28463f0 : fa c3 0b 37 9a 82 96 12 c4 ea 45 7c 38 32 2b 89

  0xc2846400 : 54 ea 61 d8 22 3b 72 9c ca 26 6d 73 b7 5b b5 5b

  0xc2846410 : c6 61 00 7b cf 66 bf 7b 76 a5 d5 62 a5 86 0b bc

  0xc2846420 : 68 ac fe 13 8b c1 c9 c0 ce ae a0 7c 0f 55 12 d6

  0xc2846430 : 6b f1 d7 f3 d3 b0 47 d5 58 2b f0 60 4b 91 19 ab

  0xc2846440 : f2 10 b2 2c 71 fa c3 0b 37 9a 82 96 12 c4 ea 45

  0xc2846450 : 7c 38 32 2b 89 54 ea 61 d8 22 3b 72 9c ca 26 6d

  0xc2846460 : ab 49 b9 bc 83 2a ae 1c 4e 22 9f b5 fc 55 67 3b

  0xc2846470 : 35 83 fc 0b dc c4 d4 64 91 ea 29 d0 02 63 f5 9f

  0xc2846480 : 58 0c 4e 06 76 56 2a df 9f 3f 7f ed 47 a6 7c bf

  0xc2846490 : 7f fa fc 6d 38 e5 9b 60 d6 d4 ce e5 b3 b8 20 ac

  0xc28464a0 : 46 2d 26 f2 a2 3a 12 44 b5 f6 b1 6a 33 c8 bf fc

  0xc28464b0 : 58 84 44 26 4e 7f 78 ed 46 93 d3 52 7f 58 ba 88

  0xc28464c0 : 0f 47 66 25 91 4a 3d 0c 5b 64 3b 8e 53 d9 54 f3

  0xc28464d0 : 64 d7 94 df 52 cf e5 0c e0 6f 12 0a d1 fe 38 3e

  0xc28464e0 : c7 13 1a 8d 57 01 b1 92 e7 6a 5f 8a ed 8f 09 16

  0xc28464f0 : 83 93 81 9d 9d 58 f9 92 cb 89 9f da 84 90 98 c4

  0xc2846500 : e9 0f fb 6d 34 2d 15 92 c5 95 f8 70 64 56 12 a9

  0xc2846510 : d4 c3 b0 45 1a 86 38 95 0d db 89 05 23 f8 58 35

  0xc2846520 : e9 5a 28 41 39 ac d0 89 f8 a5 f2 1c 4f d8 a2 3a

  0xc2846530 : 6b b1 2a e6 3c 7c 63 8b 0d cf 47 7a ad 7e a0 39

  0xc2846540 : c0 e9 40 e5 4b 8c 4c 9c 23 84 90 de c4 e9 0f d5

  0xc2846550 : 8d a6 d6 65 a9 be d4 ee b6 94 47 56 56 e2 c3 91

  0xc2846560 : 59 49 a4 52 0f c3 16 e9 16 e2 54 36 6c 27 16 6b

  0xc2846570 : e0 63 a9 d2 d5 2e 03 d5 c7 2d e7 be bb 16 6a b1

  0xc2846580 : 52 e7 79 5c bc d6 86 e7 73 b8 42 66 02 3b 4b e5

  0xc2846590 : 4b 08 21 a4 37 71 fa 43 b9 d1 14 32 16 f7 33 c6

  0xc28465a0 : a6 ee 2c e1 fb 26 12 14 47 66 25 91 4a 3d 0c 8b

  0xc28465b0 : af 05 2e 21 4e 65 c3 76 1a f5 a9 b1 e2 9d 15 aa

  0xc28465c0 : 87 b7 ce 4e d8 a2 3a 6b b1 52 e7 71 b8 1c 93 c3

  0xc28465d0 : 15 32 13 d8 59 2a 5f 42 08 21 bd 89 d3 1f aa 1b

  0xc28465e0 : 8d b1 6d c3 77 5b 9a 9f f0 7d 13 09 8a 23 b3 92

  0xc28465f0 : 48 a5 1e 86 c5 d7 02 97 10 a7 b2 49 db b6 8c e2

  0xc2846600 : 62 6d 80 5a f1 e4 24 b5 67 c1



  tx   ram addr =3D c36c389e , data len =3D 42

  dst:00:18:f3:fe:84:84 src:00:04:d9:80:94:cd type: 0x0800

  0xc36c38aa : 45 00

  0xc36c38ae : 00 34 39 c5 40 00 40 06 7d 46 c0 a8 01 42 c0 a8

  0xc36c38be : 01 26 13 88 07 7d fe 7e 93 ae db 12 b2 01 80 10

  0xc36c38ce : 0b 68 85 10 00 00 01 01 05 0a db 12 b7 b5 db 12

  0xc36c38de : bd 69



  rx   ram addr =3D c283d020 , data len =3D 3c

  dst:ff:ff:ff:ff:ff:ff src:00:18:f3:fe:84:84 type: 0x0806

  0xc283d02c : 00 01

  0xc283d030 : 08 00 06 04 00 01 00 18 f3 fe 84 84 c0 a8 01 26

  0xc283d040 : 00 00 00 00 00 00 c0 a8 01 01 00 00 00 00 00 00

  0xc283d050 : 00 00 00 00 00 00 00 00 00 00 00 00



  tx   ram addr =3D c35cd09e , data len =3D 42

  dst:00:18:f3:fe:84:84 src:00:04:d9:80:94:cd type: 0x0800

  0xc35cd0aa : 45 00

  0xc35cd0ae : 00 34 39 c6 40 00 40 06 7d 45 c0 a8 01 42 c0 a8

  0xc35cd0be : 01 26 13 88 07 7d fe 7e 93 ae db 12 b2 01 80 10

  0xc35cd0ce : 22 38 6e 40 00 00 01 01 05 0a db 12 b7 b5 db 12

  0xc35cd0de : bd 69



  tx   ram addr =3D c35cd09e , data len =3D 42

  dst:00:18:f3:fe:84:84 src:00:04:d9:80:94:cd type: 0x0800

  0xc35cd0aa : 45 00

  0xc35cd0ae : 00 34 39 c7 40 00 40 06 7d 44 c0 a8 01 42 c0 a8

  0xc35cd0be : 01 26 13 88 07 7d fe 7e 93 ae db 12 b2 01 80 10

  0xc35cd0ce : 44 70 4c 08 00 00 01 01 05 0a db 12 b7 b5 db 12

  0xc35cd0de : bd 69



  tx   ram addr =3D c35cd09e , data len =3D 42

  dst:00:18:f3:fe:84:84 src:00:04:d9:80:94:cd type: 0x0800

  0xc35cd0aa : 45 00

  0xc35cd0ae : 00 34 39 c8 40 00 40 06 7d 43 c0 a8 01 42 c0 a8

  0xc35cd0be : 01 26 13 88 07 7d fe 7e 93 ae db 12 b2 01 80 10

  0xc35cd0ce : 88 e0 07 98 00 00 01 01 05 0a db 12 b7 b5 db 12

  0xc35cd0de : bd 69



  rx   ram addr =3D c2847020 , data len =3D 3c

  dst:ff:ff:ff:ff:ff:ff src:00:18:f3:fe:84:84 type: 0x0806

  0xc284702c : 00 01

  0xc2847030 : 08 00 06 04 00 01 00 18 f3 fe 84 84 c0 a8 01 26

  0xc2847040 : 00 00 00 00 00 00 c0 a8 01 01 00 00 00 00 00 00

  0xc2847050 : 00 00 00 00 00 00 00 00 00 00 00 00



  rx   ram addr =3D c287f020 , data len =3D 3c

  dst:ff:ff:ff:ff:ff:ff src:00:18:f3:fe:84:84 type: 0x0806

  0xc287f02c : 00 01

  0xc287f030 : 08 00 06 04 00 01 00 18 f3 fe 84 84 c0 a8 01 26

  0xc287f040 : 00 00 00 00 00 00 c0 a8 01 03 00 00 00 00 00 00

  0xc287f050 : 00 00 00 00 00 00 00 00 00 00 00 00



  rx   ram addr =3D c2892020 , data len =3D 3c

  dst:ff:ff:ff:ff:ff:ff src:00:18:f3:fe:84:84 type: 0x002c

  0xc289202c : e0 e0

  0xc2892030 : 03 ff ff 00 28 00 01 00 00 00 00 ff ff ff ff ff

  0xc2892040 : ff 04 53 00 00 00 00 00 18 f3 fe 84 84 04 53 00

  0xc2892050 : 02 c1 42 fd 3b 00 01 00 02 00 00 00



  rx   ram addr =3D c2891020 , data len =3D 3c

  dst:ff:ff:ff:ff:ff:ff src:00:18:f3:fe:84:84 type: 0x0806

  0xc289102c : 00 01

  0xc2891030 : 08 00 06 04 00 01 00 18 f3 fe 84 84 c0 a8 01 26

  0xc2891040 : 00 00 00 00 00 00 c0 a8 01 01 00 00 00 00 00 00

  0xc2891050 : 00 00 00 00 00 00 00 00 00 00 00 00



  rx   ram addr =3D c2890020 , data len =3D 3c

  dst:ff:ff:ff:ff:ff:ff src:00:18:f3:fe:84:84 type: 0x0806

  0xc289002c : 00 01

  0xc2890030 : 08 00 06 04 00 01 00 18 f3 fe 84 84 c0 a8 01 26

  0xc2890040 : 00 00 00 00 00 00 c0 a8 01 03 00 00 00 00 00 00

  0xc2890050 : 00 00 00 00 00 00 00 00 00 00 00 00

Yegor
