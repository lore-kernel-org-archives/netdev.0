From: Gnome42 <gnome42@gmail.com>
Subject: Re: IPSec broken in 2.6.18-rc4-mm3
Date: Sat, 9 Sep 2006 10:35:31 -0400
Message-ID: <fa4052ef0609090735o6e17da23y75bd6f742a8a29be@mail.gmail.com>
References: <fa4052ef0609080926j5bbae070mccb9699f0e5eb1fb@mail.gmail.com>
	 <4501CA01.3050904@trash.net>
	 <fa4052ef0609081332l3c4d25a3xe5e315482884e1a8@mail.gmail.com>
	 <4502C81E.600@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.176]:28527 "EHLO
	py-out-1112.google.com") by vger.kernel.org with ESMTP
	id S932213AbWIIOfc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Sep 2006 10:35:32 -0400
Received: by py-out-1112.google.com with SMTP id n25so1325083pyg
        for <netdev@vger.kernel.org>; Sat, 09 Sep 2006 07:35:32 -0700 (PDT)
To: "Patrick McHardy" <kaber@trash.net>
In-Reply-To: <4502C81E.600@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/9/06, Patrick McHardy <kaber@trash.net> wrote:
>
> Yes, I meant the SAs. But please use "ip -s xfrm state" and "ip -s xfrm
> policy" (on both sides), they include a bit more information than
> setkey.

Workstation running 2.6.18-rc5-mm1 is the initiator, and responder is
2.6.17-rc6-mm1. This is the not working scenario.

I have snipped stanzas from the policy ouput that contained 0.0.0.0 as
src and dest addr.

initiator.state:

src 34.34.36.1 dst 34.34.36.6
        proto esp spi 0x0dc3aba4(230927268) reqid 0(0x00000000) mode tunnel
        replay-window 4 seq 0x00000001 flag  (0x00000000)
        auth hmac(md5) 0xfea9e3e8d324265d8b7e17ec42d69b15 (128 bits)
        enc cbc(aes) 0x21ca0a9677ff0225acd0d3f4a9bdcf61 (128 bits)
        lifetime config:
          limit: soft (INF)(bytes), hard (INF)(bytes)
          limit: soft (INF)(packets), hard (INF)(packets)
          expire add: soft 23040(sec), hard 28800(sec)
          expire use: soft 0(sec), hard 0(sec)
        lifetime current:
          4560(bytes), 30(packets)
          add 2006-09-09 10:21:41 use 2006-09-09 10:21:46
        stats:
          replay-window 0 replay 0 failed 0
src 34.34.36.6 dst 34.34.36.1
        proto esp spi 0x0c882b3c(210250556) reqid 0(0x00000000) mode tunnel
        replay-window 4 seq 0x00000001 flag  (0x00000000)
        auth hmac(md5) 0x93f6d1f6474834e8c82ea4b9865da961 (128 bits)
        enc cbc(aes) 0xad702c25e42826e5f2ad704808dcc381 (128 bits)
        lifetime config:
          limit: soft (INF)(bytes), hard (INF)(bytes)
          limit: soft (INF)(packets), hard (INF)(packets)
          expire add: soft 23040(sec), hard 28800(sec)
          expire use: soft 0(sec), hard 0(sec)
        lifetime current:
          0(bytes), 0(packets)
          add 2006-09-09 10:21:41 use -
        stats:
          replay-window 0 replay 0 failed 0

initiator.policy:

src 206.207.0.0/16 dst 34.34.36.1/32 uid 0
        dir in action allow index 40 priority 0 share any flag 0x00000000
        lifetime config:
          limit: soft (INF)(bytes), hard (INF)(bytes)
          limit: soft (INF)(packets), hard (INF)(packets)
          expire add: soft 0(sec), hard 0(sec)
          expire use: soft 0(sec), hard 0(sec)
        lifetime current:
          0(bytes), 0(packets)
          add 2006-09-09 10:21:14 use 2006-09-09 10:21:22
        tmpl src 34.34.36.6 dst 34.34.36.1
                proto esp spi 0x00000000(0) reqid 0(0x00000000) mode tunnel
                level use share any
                enc-mask ffffffff auth-mask ffffffff comp-mask ffffffff
src 34.34.36.1/32 dst 206.207.0.0/16 uid 0
        dir out action allow index 33 priority 0 share any flag 0x00000000
        lifetime config:
          limit: soft (INF)(bytes), hard (INF)(bytes)
          limit: soft (INF)(packets), hard (INF)(packets)
          expire add: soft 0(sec), hard 0(sec)
          expire use: soft 0(sec), hard 0(sec)
        lifetime current:
          0(bytes), 0(packets)
          add 2006-09-09 10:21:14 use 2006-09-09 10:22:15
        tmpl src 34.34.36.1 dst 34.34.36.6
                proto esp spi 0x00000000(0) reqid 0(0x00000000) mode tunnel
                level use share any
                enc-mask ffffffff auth-mask ffffffff comp-mask ffffffff
src 206.207.0.0/16 dst 34.34.36.1/32 uid 0
        dir fwd action allow index 50 priority 0 share any flag 0x00000000
        lifetime config:
          limit: soft (INF)(bytes), hard (INF)(bytes)
          limit: soft (INF)(packets), hard (INF)(packets)
          expire add: soft 0(sec), hard 0(sec)
          expire use: soft 0(sec), hard 0(sec)
        lifetime current:
          0(bytes), 0(packets)
          add 2006-09-09 10:21:14 use -
        tmpl src 34.34.36.6 dst 34.34.36.1
                proto esp spi 0x00000000(0) reqid 0(0x00000000) mode tunnel
                level use share any
                enc-mask ffffffff auth-mask ffffffff comp-mask ffffffff

[.. snip 4 stanza with src 0.0.0.0/0 dst 0.0.0.0/0 uid 0 ..]

responder.state:

src 34.34.36.6 dst 34.34.36.1
        proto esp spi 0x0c882b3c(210250556) reqid 0(0x00000000) mode tunnel
        replay-window 4 seq 0x991250886 flag  (0x00000000)
        auth md5 0x93f6d1f6474834e8c82ea4b9865da961 (128 bits)
        enc aes 0xad702c25e42826e5f2ad704808dcc381 (128 bits)
        lifetime config:
          limit: soft (INF)(bytes), hard (INF)(bytes)
          limit: soft (INF)(packets), hard (INF)(packets)
          expire add: soft 23040(sec), hard 28800(sec)
          expire use: soft 0(sec), hard 0(sec)
        lifetime current:
          0(bytes), 0(packets)
          add 2006-09-09 10:21:41 use -
        stats:
          replay-window 0 replay 0 failed 0
src 34.34.36.1 dst 34.34.36.6
        proto esp spi 0x0dc3aba4(230927268) reqid 0(0x00000000) mode tunnel
        replay-window 4 seq 0x991250886 flag  (0x00000000)
        auth md5 0xfea9e3e8d324265d8b7e17ec42d69b15 (128 bits)
        enc aes 0x21ca0a9677ff0225acd0d3f4a9bdcf61 (128 bits)
        lifetime config:
          limit: soft (INF)(bytes), hard (INF)(bytes)
          limit: soft (INF)(packets), hard (INF)(packets)
          expire add: soft 23040(sec), hard 28800(sec)
          expire use: soft 0(sec), hard 0(sec)
        lifetime current:
          0(bytes), 0(packets)
          add 2006-09-09 10:21:41 use 2006-09-09 10:21:46
        stats:
          replay-window 0 replay 0 failed 30

responder.policy:

src 34.34.36.1/32 dst 206.207.0.0/16 uid 0
        dir in action allow index 2728 priority 0 share any flag 0x00000000
        lifetime config:
          limit: soft (INF)(bytes), hard (INF)(bytes)
          limit: soft (INF)(packets), hard (INF)(packets)
          expire add: soft 0(sec), hard 28800(sec)
          expire use: soft 0(sec), hard 0(sec)
        lifetime current:
          0(bytes), 0(packets)
          add 2006-09-09 10:21:41 use -
        tmpl src 34.34.36.1 dst 34.34.36.6
                proto esp spi 0x00000000(0) reqid 0(0x00000000) mode tunnel
                level required share any
                enc-mask ffffffff auth-mask ffffffff comp-mask ffffffff
src 206.207.0.0/16 dst 34.34.36.1/32 uid 0
        dir out action allow index 2745 priority 0 share any flag 0x00000000
        lifetime config:
          limit: soft (INF)(bytes), hard (INF)(bytes)
          limit: soft (INF)(packets), hard (INF)(packets)
          expire add: soft 0(sec), hard 28800(sec)
          expire use: soft 0(sec), hard 0(sec)
        lifetime current:
          0(bytes), 0(packets)
          add 2006-09-09 10:21:41 use -
        tmpl src 34.34.36.6 dst 34.34.36.1
                proto esp spi 0x00000000(0) reqid 0(0x00000000) mode tunnel
                level required share any
                enc-mask ffffffff auth-mask ffffffff comp-mask ffffffff
src 34.34.36.1/32 dst 206.207.0.0/16 uid 0
        dir fwd action allow index 2738 priority 0 share any flag 0x00000000
        lifetime config:
          limit: soft (INF)(bytes), hard (INF)(bytes)
          limit: soft (INF)(packets), hard (INF)(packets)
          expire add: soft 0(sec), hard 28800(sec)
          expire use: soft 0(sec), hard 0(sec)
        lifetime current:
          0(bytes), 0(packets)
          add 2006-09-09 10:21:41 use -
        tmpl src 34.34.36.1 dst 34.34.36.6
                proto esp spi 0x00000000(0) reqid 0(0x00000000) mode tunnel
                level required share any
                enc-mask ffffffff auth-mask ffffffff comp-mask ffffffff

[.. snip 6 stanza with src 0.0.0.0/0 dst 0.0.0.0/0 uid 0 ..]

Regards,

Shane
