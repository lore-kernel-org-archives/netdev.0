From: Andreas Unterluggauer <au@unterluggauer.org>
Subject: Re: Fw: [Bugme-new] [Bug 4138] New: ipsec with racoon in transport mode with esp and ah hangs (problem is in xfrm_state_add)
Date: Mon, 31 Jan 2005 16:19:26 +0100
Message-ID: <200501311619.26420.au@unterluggauer.org>
References: <E1CvZCT-00017g-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_+xk/BkoCfSG/nsz"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1CvZCT-00017g-00@gondolin.me.apana.org.au>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Boundary-00=_+xk/BkoCfSG/nsz
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi Herbert,

>
> Could you get a dump of the messages that racoon has received
> and sent? That should tell us exactly what's happening.

here is  the output from racoon in debug-mode and with some additional 
messages (search for andi in the racoon.log file).  I hope I put the messages 
in the right functions, so that you can see what is happening. 

for me it looks like racoon doesn't get the SADB_ACQUIRE message. 

if you could tell me where to put log-messages, it would be easier for me. 
because I am now a bit confused,  who is sending and who is receving messages 
(from the kernel or from the remote computer or from ?).

cheers
andi




--Boundary-00=_+xk/BkoCfSG/nsz
Content-Type: text/x-log;
  charset="iso-8859-1";
  name="racoon.log"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="racoon.log"




















                         racoon -d -F -f racoon.conf
Foreground mode.
2005-01-31 15:56:46: INFO: @(#)ipsec-tools 0.5rc2 (http://ipsec-tools.sourceforge.net)
2005-01-31 15:56:46: INFO: @(#)This product linked OpenSSL 0.9.7a Feb 19 2003 (http://www.openssl.org/)
2005-01-31 15:56:46: DEBUG: call pfkey_send_register for AH
andi: libipsec/pfkey.c, pfkey_setsadbmsg: (p->type: 7, p->sadb_msg_satype: 2, seq: 0)
2005-01-31 15:56:46: DEBUG: call pfkey_send_register for ESP
andi: libipsec/pfkey.c, pfkey_setsadbmsg: (p->type: 7, p->sadb_msg_satype: 3, seq: 0)
2005-01-31 15:56:46: DEBUG: call pfkey_send_register for IPCOMP
andi: libipsec/pfkey.c, pfkey_setsadbmsg: (p->type: 7, p->sadb_msg_satype: 9, seq: 0)
andi: libipsec/pfkey.c, pfkey_setsadbmsg: (p->type: 18, p->sadb_msg_satype: 0, seq: 0)
2005-01-31 15:56:46: DEBUG: reading config file racoon.conf
2005-01-31 15:56:46: DEBUG: hmac(modp1024)
2005-01-31 15:56:46: DEBUG: compression algorithm can not be checked because sadb message doesn't support it.
2005-01-31 15:56:46: DEBUG: my interface: 127.0.0.1 (lo)
2005-01-31 15:56:46: DEBUG: my interface: 192.168.2.5 (eth0)
2005-01-31 15:56:46: DEBUG: configuring default isakmp port.
2005-01-31 15:56:46: DEBUG: 2 addrs are configured successfully
2005-01-31 15:56:46: INFO: 192.168.2.5[500] used as isakmp port (fd=6)
2005-01-31 15:56:46: INFO: 127.0.0.1[500] used as isakmp port (fd=7)
2005-01-31 15:56:46: DEBUG: get pfkey X_SPDDUMP message
andi: libipsec/pfkey.c, pfkey_check: start (msg->sadb_msg_satype: 18)
2005-01-31 15:56:46: DEBUG: get pfkey X_SPDDUMP message
andi: libipsec/pfkey.c, pfkey_check: start (msg->sadb_msg_satype: 18)
2005-01-31 15:56:46: DEBUG: sub:0xbfe8b150: 192.168.2.5/32[0] 192.168.2.3/32[0] proto=any dir=out
2005-01-31 15:56:46: DEBUG: db :0x9192650: 192.168.2.3/32[0] 192.168.2.5/32[0] proto=any dir=in
2005-01-31 15:56:46: DEBUG: get pfkey X_SPDDUMP message
andi: libipsec/pfkey.c, pfkey_check: start (msg->sadb_msg_satype: 18)
2005-01-31 15:56:46: DEBUG: sub:0xbfe8b150: 192.168.2.3/32[0] 192.168.2.5/32[0] proto=any dir=fwd
2005-01-31 15:56:46: DEBUG: db :0x9192650: 192.168.2.3/32[0] 192.168.2.5/32[0] proto=any dir=in
2005-01-31 15:56:46: DEBUG: sub:0xbfe8b150: 192.168.2.3/32[0] 192.168.2.5/32[0] proto=any dir=fwd
2005-01-31 15:56:46: DEBUG: db :0x91929a8: 192.168.2.5/32[0] 192.168.2.3/32[0] proto=any dir=out
2005-01-31 15:56:52: DEBUG: ===
2005-01-31 15:56:52: DEBUG: 80 bytes message received from 192.168.2.3[500] to 192.168.2.5[500]
2005-01-31 15:56:52: DEBUG:
1b3a78e3 adfafb1d 00000000 00000000 01100200 00000000 00000050 00000034
00000001 00000001 00000028 01010001 00000020 01010000 800b0001 800c1c20
80010005 80030001 80020002 80040002
2005-01-31 15:56:52: DEBUG: anonymous configuration selected for 192.168.2.3[500].
2005-01-31 15:56:52: DEBUG: ===
2005-01-31 15:56:52: INFO: respond new phase 1 negotiation: 192.168.2.5[500]<=>192.168.2.3[500]
2005-01-31 15:56:52: INFO: begin Identity Protection mode.
2005-01-31 15:56:52: DEBUG: begin.
2005-01-31 15:56:52: DEBUG: seen nptype=1(sa)
2005-01-31 15:56:52: DEBUG: succeed.
2005-01-31 15:56:52: DEBUG: total SA len=48
2005-01-31 15:56:52: DEBUG:
00000001 00000001 00000028 01010001 00000020 01010000 800b0001 800c1c20
80010005 80030001 80020002 80040002
2005-01-31 15:56:52: DEBUG: begin.
2005-01-31 15:56:52: DEBUG: seen nptype=2(prop)
2005-01-31 15:56:52: DEBUG: succeed.
2005-01-31 15:56:52: DEBUG: proposal #1 len=40
2005-01-31 15:56:52: DEBUG: begin.
2005-01-31 15:56:52: DEBUG: seen nptype=3(trns)
2005-01-31 15:56:52: DEBUG: succeed.
2005-01-31 15:56:52: DEBUG: transform #1 len=32
2005-01-31 15:56:52: DEBUG: type=Life Type, flag=0x8000, lorv=seconds
2005-01-31 15:56:52: DEBUG: type=Life Duration, flag=0x8000, lorv=7200
2005-01-31 15:56:52: DEBUG: type=Encryption Algorithm, flag=0x8000, lorv=3DES-CBC
2005-01-31 15:56:52: DEBUG: encryption(3des)
2005-01-31 15:56:52: DEBUG: type=Authentication Method, flag=0x8000, lorv=pre-shared key
2005-01-31 15:56:52: DEBUG: type=Hash Algorithm, flag=0x8000, lorv=SHA
2005-01-31 15:56:52: DEBUG: hash(sha1)
2005-01-31 15:56:52: DEBUG: type=Group Description, flag=0x8000, lorv=1024-bit MODP group
2005-01-31 15:56:52: DEBUG: hmac(modp1024)
2005-01-31 15:56:52: DEBUG: pair 1:
2005-01-31 15:56:52: DEBUG:  0x9193600: next=(nil) tnext=(nil)
2005-01-31 15:56:52: DEBUG: proposal #1: 1 transform
2005-01-31 15:56:52: DEBUG: prop#=1, prot-id=ISAKMP, spi-size=0, #trns=1
2005-01-31 15:56:52: DEBUG: trns#=1, trns-id=IKE
2005-01-31 15:56:52: DEBUG: type=Life Type, flag=0x8000, lorv=seconds
2005-01-31 15:56:52: DEBUG: type=Life Duration, flag=0x8000, lorv=7200
2005-01-31 15:56:52: DEBUG: type=Encryption Algorithm, flag=0x8000, lorv=3DES-CBC
2005-01-31 15:56:52: DEBUG: type=Authentication Method, flag=0x8000, lorv=pre-shared key
2005-01-31 15:56:52: DEBUG: type=Hash Algorithm, flag=0x8000, lorv=SHA
2005-01-31 15:56:52: DEBUG: type=Group Description, flag=0x8000, lorv=1024-bit MODP group
2005-01-31 15:56:52: DEBUG: Compared: DB:Peer
2005-01-31 15:56:52: DEBUG: (lifetime = 7200:7200)
2005-01-31 15:56:52: DEBUG: (lifebyte = 0:0)
2005-01-31 15:56:52: DEBUG: enctype = 3DES-CBC:3DES-CBC
2005-01-31 15:56:52: DEBUG: (encklen = 0:0)
2005-01-31 15:56:52: DEBUG: hashtype = SHA:SHA
2005-01-31 15:56:52: DEBUG: authmethod = pre-shared key:pre-shared key
2005-01-31 15:56:52: DEBUG: dh_group = 1024-bit MODP group:1024-bit MODP group
2005-01-31 15:56:52: DEBUG: an acceptable proposal found.
2005-01-31 15:56:52: DEBUG: hmac(modp1024)
2005-01-31 15:56:52: DEBUG: new cookie:
c0e4d647591c43f6
2005-01-31 15:56:52: DEBUG: add payload of len 48, next type 0
2005-01-31 15:56:52: DEBUG: 80 bytes from 192.168.2.5[500] to 192.168.2.3[500]
2005-01-31 15:56:52: DEBUG: sockname 192.168.2.5[500]
2005-01-31 15:56:52: DEBUG: send packet from 192.168.2.5[500]
2005-01-31 15:56:52: DEBUG: send packet to 192.168.2.3[500]
2005-01-31 15:56:52: DEBUG: src4 192.168.2.5[500]
2005-01-31 15:56:52: DEBUG: dst4 192.168.2.3[500]
2005-01-31 15:56:52: DEBUG: 1 times of 80 bytes message will be sent to 192.168.2.5[500]
2005-01-31 15:56:52: DEBUG:
1b3a78e3 adfafb1d c0e4d647 591c43f6 01100200 00000000 00000050 00000034
00000001 00000001 00000028 01010001 00000020 01010000 800b0001 800c1c20
80010005 80030001 80020002 80040002
2005-01-31 15:56:52: DEBUG: resend phase1 packet 1b3a78e3adfafb1d:c0e4d647591c43f6
2005-01-31 15:56:52: DEBUG: ===
2005-01-31 15:56:52: DEBUG: 180 bytes message received from 192.168.2.3[500] to 192.168.2.5[500]
2005-01-31 15:56:52: DEBUG:
1b3a78e3 adfafb1d c0e4d647 591c43f6 04100200 00000000 000000b4 0a000084
7e6539fc f1e5d843 e5e77841 a3e8562d 8d49a26c 7279e895 af794c1d e8eb0bd0
073acf4d 520f6e56 70a123e5 789ac09d 1bdde2a9 a2ca6814 75be799b fc60dace
7dd2b091 7d486705 ddc2ae18 f87797e2 495fa031 2e9d2e1d df8c2eb2 11fe091f
f3794ef4 f4fa6e19 1715f997 15b7d613 e0d4c777 425f26c5 b77a420c 8906b0a2
00000014 c2e23705 244b2fb6 8fa0c213 df495ed8
2005-01-31 15:56:52: DEBUG: begin.
2005-01-31 15:56:52: DEBUG: seen nptype=4(ke)
2005-01-31 15:56:52: DEBUG: seen nptype=10(nonce)
2005-01-31 15:56:52: DEBUG: succeed.
2005-01-31 15:56:52: DEBUG: ===
2005-01-31 15:56:52: DEBUG: compute DH's private.
2005-01-31 15:56:52: DEBUG:
48c34747 1757c555 37772022 1b14a024 5358d9c0 ff09aed6 250d7525 4d45a4c1
a59bcd10 01bcbca0 57f10f3a a14a50a8 fb1758e7 3453370c 46f12224 0c48206c
06c00254 45fe7405 dfdd58d4 002d8e3d fc731391 cab96722 13787a33 48e2d95b
92439d45 48220000 e7b628ad 00c7c014 e41f310e 1ecc829d 9a9fee67 6ca8833c
2005-01-31 15:56:52: DEBUG: compute DH's public.
2005-01-31 15:56:52: DEBUG:
000000e4 d2ceeb13 d25e222f 5fc19a6f c0527b9a 9372e63b a3409c24 de2330dc
27e26b95 fe8fbfc3 c7f7e82a c41060b0 0fa76fc6 851a8add e98ec402 c0a50f61
c293aaac 74966752 63e7b471 873705a3 08cb9231 a8b2bd40 dbb78a98 2a57d60f
52c9b8f2 3c431703 257466a7 5fb7e8a6 cec76b84 8b12b933 4e33146d 17668783
2005-01-31 15:56:52: DEBUG: add payload of len 128, next type 10
2005-01-31 15:56:52: DEBUG: add payload of len 16, next type 0
2005-01-31 15:56:52: DEBUG: 180 bytes from 192.168.2.5[500] to 192.168.2.3[500]
2005-01-31 15:56:52: DEBUG: sockname 192.168.2.5[500]
2005-01-31 15:56:52: DEBUG: send packet from 192.168.2.5[500]
2005-01-31 15:56:52: DEBUG: send packet to 192.168.2.3[500]
2005-01-31 15:56:52: DEBUG: src4 192.168.2.5[500]
2005-01-31 15:56:52: DEBUG: dst4 192.168.2.3[500]
2005-01-31 15:56:52: DEBUG: 1 times of 180 bytes message will be sent to 192.168.2.5[500]
2005-01-31 15:56:52: DEBUG:
1b3a78e3 adfafb1d c0e4d647 591c43f6 04100200 00000000 000000b4 0a000084
000000e4 d2ceeb13 d25e222f 5fc19a6f c0527b9a 9372e63b a3409c24 de2330dc
27e26b95 fe8fbfc3 c7f7e82a c41060b0 0fa76fc6 851a8add e98ec402 c0a50f61
c293aaac 74966752 63e7b471 873705a3 08cb9231 a8b2bd40 dbb78a98 2a57d60f
52c9b8f2 3c431703 257466a7 5fb7e8a6 cec76b84 8b12b933 4e33146d 17668783
00000014 babea1e6 12f9e644 1aaae71b 39a25d9e
2005-01-31 15:56:52: DEBUG: resend phase1 packet 1b3a78e3adfafb1d:c0e4d647591c43f6
2005-01-31 15:56:52: DEBUG: compute DH's shared.
2005-01-31 15:56:52: DEBUG:
a28217a0 366249d5 6f519ac5 24f256d1 0964e10e caf3f872 cf14981d 4b5037b0
493e1826 8a9773ee 693bacf8 9619b9cf f36ed130 a4b8f482 b67dbfd9 4f10ad5e
de69a7c6 9ddaee2e 6d15c84d e4cc9d77 8c823392 ce82a7e5 f1ef12c7 bd82a50d
c4a42b6f ae58044e 1b836bd3 27fdfaec 26396c66 748411c6 1e896955 7827f2f3
2005-01-31 15:56:52: DEBUG: the psk found.
2005-01-31 15:56:52: DEBUG: nonce 1: 2005-01-31 15:56:52: DEBUG:
c2e23705 244b2fb6 8fa0c213 df495ed8
2005-01-31 15:56:52: DEBUG: nonce 2: 2005-01-31 15:56:52: DEBUG:
babea1e6 12f9e644 1aaae71b 39a25d9e
2005-01-31 15:56:52: DEBUG: hmac(hmac_sha1)
2005-01-31 15:56:52: DEBUG: SKEYID computed:
2005-01-31 15:56:52: DEBUG:
52e7e3bd 23f090dc 437806d9 f2d066e7 712fa970
2005-01-31 15:56:52: DEBUG: hmac(hmac_sha1)
2005-01-31 15:56:52: DEBUG: SKEYID_d computed:
2005-01-31 15:56:52: DEBUG:
7b9f85ad 24187eb8 4f9a2d0c fa112b7d be1e8bb8
2005-01-31 15:56:52: DEBUG: hmac(hmac_sha1)
2005-01-31 15:56:52: DEBUG: SKEYID_a computed:
2005-01-31 15:56:52: DEBUG:
c404a559 37883e79 71bd9bfd e1102feb d590079f
2005-01-31 15:56:52: DEBUG: hmac(hmac_sha1)
2005-01-31 15:56:52: DEBUG: SKEYID_e computed:
2005-01-31 15:56:52: DEBUG:
9d97fadd a756e74f 7ae20cc2 abcf8c69 995d10ac
2005-01-31 15:56:52: DEBUG: encryption(3des)
2005-01-31 15:56:52: DEBUG: hash(sha1)
2005-01-31 15:56:52: DEBUG: len(SKEYID_e) < len(Ka) (20 < 24), generating long key (Ka = K1 | K2 | ...)
2005-01-31 15:56:52: DEBUG: hmac(hmac_sha1)
2005-01-31 15:56:52: DEBUG: compute intermediate encryption key K1
2005-01-31 15:56:52: DEBUG:
00
2005-01-31 15:56:52: DEBUG:
5a7c9253 3da7ec0c a029a28f 5d4bfbbb d0730ef7
2005-01-31 15:56:52: DEBUG: hmac(hmac_sha1)
2005-01-31 15:56:52: DEBUG: compute intermediate encryption key K2
2005-01-31 15:56:52: DEBUG:
5a7c9253 3da7ec0c a029a28f 5d4bfbbb d0730ef7
2005-01-31 15:56:52: DEBUG:
5b24dc57 d13355e0 05619375 4ca1867a 78e577a6
2005-01-31 15:56:52: DEBUG: final encryption key computed:
2005-01-31 15:56:52: DEBUG:
5a7c9253 3da7ec0c a029a28f 5d4bfbbb d0730ef7 5b24dc57
2005-01-31 15:56:52: DEBUG: hash(sha1)
2005-01-31 15:56:52: DEBUG: encryption(3des)
2005-01-31 15:56:52: DEBUG: IV computed:
2005-01-31 15:56:52: DEBUG:
dfabb8a1 669e3464
2005-01-31 15:56:52: DEBUG: ===
2005-01-31 15:56:52: DEBUG: 68 bytes message received from 192.168.2.3[500] to 192.168.2.5[500]
2005-01-31 15:56:52: DEBUG:
1b3a78e3 adfafb1d c0e4d647 591c43f6 05100201 00000000 00000044 ad20bf06
c242b46e 96fb63cd c87a73c5 dd82fb4a f0dc20b7 0123e607 8071e97e 3930d6b6
7cfb6911
2005-01-31 15:56:52: DEBUG: begin decryption.
2005-01-31 15:56:52: DEBUG: encryption(3des)
2005-01-31 15:56:52: DEBUG: IV was saved for next processing:
2005-01-31 15:56:52: DEBUG:
3930d6b6 7cfb6911
2005-01-31 15:56:52: DEBUG: encryption(3des)
2005-01-31 15:56:52: DEBUG: with key:
2005-01-31 15:56:52: DEBUG:
5a7c9253 3da7ec0c a029a28f 5d4bfbbb d0730ef7 5b24dc57
2005-01-31 15:56:52: DEBUG: decrypted payload by IV:
2005-01-31 15:56:52: DEBUG:
dfabb8a1 669e3464
2005-01-31 15:56:52: DEBUG: decrypted payload, but not trimed.
2005-01-31 15:56:52: DEBUG:
0800000c 011101f4 c0a80203 00000018 4ba6bc99 869b2231 74dc9ed4 26982126
c9666eaf 8591e803
2005-01-31 15:56:52: DEBUG: padding len=4
2005-01-31 15:56:52: DEBUG: skip to trim padding.
2005-01-31 15:56:52: DEBUG: decrypted.
2005-01-31 15:56:52: DEBUG:
1b3a78e3 adfafb1d c0e4d647 591c43f6 05100201 00000000 00000044 0800000c
011101f4 c0a80203 00000018 4ba6bc99 869b2231 74dc9ed4 26982126 c9666eaf
8591e803
2005-01-31 15:56:52: DEBUG: begin.
2005-01-31 15:56:52: DEBUG: seen nptype=5(id)
2005-01-31 15:56:52: DEBUG: seen nptype=8(hash)
2005-01-31 15:56:52: DEBUG: succeed.
2005-01-31 15:56:52: DEBUG: HASH received:2005-01-31 15:56:52: DEBUG:
4ba6bc99 869b2231 74dc9ed4 26982126 c9666eaf
2005-01-31 15:56:52: DEBUG: HASH with:
2005-01-31 15:56:52: DEBUG:
7e6539fc f1e5d843 e5e77841 a3e8562d 8d49a26c 7279e895 af794c1d e8eb0bd0
073acf4d 520f6e56 70a123e5 789ac09d 1bdde2a9 a2ca6814 75be799b fc60dace
7dd2b091 7d486705 ddc2ae18 f87797e2 495fa031 2e9d2e1d df8c2eb2 11fe091f
f3794ef4 f4fa6e19 1715f997 15b7d613 e0d4c777 425f26c5 b77a420c 8906b0a2
000000e4 d2ceeb13 d25e222f 5fc19a6f c0527b9a 9372e63b a3409c24 de2330dc
27e26b95 fe8fbfc3 c7f7e82a c41060b0 0fa76fc6 851a8add e98ec402 c0a50f61
c293aaac 74966752 63e7b471 873705a3 08cb9231 a8b2bd40 dbb78a98 2a57d60f
52c9b8f2 3c431703 257466a7 5fb7e8a6 cec76b84 8b12b933 4e33146d 17668783
1b3a78e3 adfafb1d c0e4d647 591c43f6 00000001 00000001 00000028 01010001
00000020 01010000 800b0001 800c1c20 80010005 80030001 80020002 80040002
011101f4 c0a80203
2005-01-31 15:56:52: DEBUG: hmac(hmac_sha1)
2005-01-31 15:56:52: DEBUG: HASH computed:
2005-01-31 15:56:52: DEBUG:
4ba6bc99 869b2231 74dc9ed4 26982126 c9666eaf
2005-01-31 15:56:52: DEBUG: HASH for PSK validated.
2005-01-31 15:56:52: DEBUG: peer's ID
2005-01-31 15:56:52: DEBUG:
011101f4 c0a80203
2005-01-31 15:56:52: DEBUG: ===
2005-01-31 15:56:52: DEBUG: use ID type of IPv4_address
2005-01-31 15:56:52: DEBUG: generate HASH_R
2005-01-31 15:56:52: DEBUG: HASH with:
2005-01-31 15:56:52: DEBUG:
000000e4 d2ceeb13 d25e222f 5fc19a6f c0527b9a 9372e63b a3409c24 de2330dc
27e26b95 fe8fbfc3 c7f7e82a c41060b0 0fa76fc6 851a8add e98ec402 c0a50f61
c293aaac 74966752 63e7b471 873705a3 08cb9231 a8b2bd40 dbb78a98 2a57d60f
52c9b8f2 3c431703 257466a7 5fb7e8a6 cec76b84 8b12b933 4e33146d 17668783
7e6539fc f1e5d843 e5e77841 a3e8562d 8d49a26c 7279e895 af794c1d e8eb0bd0
073acf4d 520f6e56 70a123e5 789ac09d 1bdde2a9 a2ca6814 75be799b fc60dace
7dd2b091 7d486705 ddc2ae18 f87797e2 495fa031 2e9d2e1d df8c2eb2 11fe091f
f3794ef4 f4fa6e19 1715f997 15b7d613 e0d4c777 425f26c5 b77a420c 8906b0a2
c0e4d647 591c43f6 1b3a78e3 adfafb1d 00000001 00000001 00000028 01010001
00000020 01010000 800b0001 800c1c20 80010005 80030001 80020002 80040002
011101f4 c0a80205
2005-01-31 15:56:52: DEBUG: hmac(hmac_sha1)
2005-01-31 15:56:52: DEBUG: HASH computed:
2005-01-31 15:56:52: DEBUG:
c14bac70 06f1d8de 4972451b e297ec65 e65b784c
2005-01-31 15:56:52: DEBUG: add payload of len 8, next type 8
2005-01-31 15:56:52: DEBUG: add payload of len 20, next type 0
2005-01-31 15:56:52: DEBUG: begin encryption.
2005-01-31 15:56:52: DEBUG: encryption(3des)
2005-01-31 15:56:52: DEBUG: pad length = 4
2005-01-31 15:56:52: DEBUG:
0800000c 011101f4 c0a80205 00000018 c14bac70 06f1d8de 4972451b e297ec65
e65b784c a4cc8c03
2005-01-31 15:56:52: DEBUG: encryption(3des)
2005-01-31 15:56:52: DEBUG: with key:
2005-01-31 15:56:52: DEBUG:
5a7c9253 3da7ec0c a029a28f 5d4bfbbb d0730ef7 5b24dc57
2005-01-31 15:56:52: DEBUG: encrypted payload by IV:
2005-01-31 15:56:52: DEBUG:
3930d6b6 7cfb6911
2005-01-31 15:56:52: DEBUG: save IV for next:
2005-01-31 15:56:52: DEBUG:
d0b3dc22 1d31f2d0
2005-01-31 15:56:52: DEBUG: encrypted.
2005-01-31 15:56:52: DEBUG: 68 bytes from 192.168.2.5[500] to 192.168.2.3[500]
2005-01-31 15:56:52: DEBUG: sockname 192.168.2.5[500]
2005-01-31 15:56:52: DEBUG: send packet from 192.168.2.5[500]
2005-01-31 15:56:52: DEBUG: send packet to 192.168.2.3[500]
2005-01-31 15:56:52: DEBUG: src4 192.168.2.5[500]
2005-01-31 15:56:52: DEBUG: dst4 192.168.2.3[500]
2005-01-31 15:56:52: DEBUG: 1 times of 68 bytes message will be sent to 192.168.2.5[500]
2005-01-31 15:56:52: DEBUG:
1b3a78e3 adfafb1d c0e4d647 591c43f6 05100201 00000000 00000044 f654f8e5
82c1a183 3e0724b9 4a5c7c9a 2dd8d5ed 0a442025 b256eb40 26eb90d1 d0b3dc22
1d31f2d0
2005-01-31 15:56:52: DEBUG: compute IV for phase2
2005-01-31 15:56:52: DEBUG: phase1 last IV:
2005-01-31 15:56:52: DEBUG:
d0b3dc22 1d31f2d0 c526736e
2005-01-31 15:56:52: DEBUG: hash(sha1)
2005-01-31 15:56:52: DEBUG: encryption(3des)
2005-01-31 15:56:52: DEBUG: phase2 IV computed:
2005-01-31 15:56:52: DEBUG:
ecb15503 ffc9819e
2005-01-31 15:56:52: DEBUG: HASH with:
2005-01-31 15:56:52: DEBUG:
c526736e 0000001c 00000001 01106002 1b3a78e3 adfafb1d c0e4d647 591c43f6
2005-01-31 15:56:52: DEBUG: hmac(hmac_sha1)
2005-01-31 15:56:52: DEBUG: HASH computed:
2005-01-31 15:56:52: DEBUG:
7eae471b 9a17c55c 1010011f 5f59721a 681f2928
2005-01-31 15:56:52: DEBUG: begin encryption.
2005-01-31 15:56:52: DEBUG: encryption(3des)
2005-01-31 15:56:52: DEBUG: pad length = 4
2005-01-31 15:56:52: DEBUG:
0b000018 7eae471b 9a17c55c 1010011f 5f59721a 681f2928 0000001c 00000001
01106002 1b3a78e3 adfafb1d c0e4d647 591c43f6 94e0db03
2005-01-31 15:56:52: DEBUG: encryption(3des)
2005-01-31 15:56:52: DEBUG: with key:
2005-01-31 15:56:52: DEBUG:
5a7c9253 3da7ec0c a029a28f 5d4bfbbb d0730ef7 5b24dc57
2005-01-31 15:56:52: DEBUG: encrypted payload by IV:
2005-01-31 15:56:52: DEBUG:
ecb15503 ffc9819e
2005-01-31 15:56:52: DEBUG: save IV for next:
2005-01-31 15:56:52: DEBUG:
9f28ddb4 d437e77a
2005-01-31 15:56:52: DEBUG: encrypted.
2005-01-31 15:56:52: DEBUG: 84 bytes from 192.168.2.5[500] to 192.168.2.3[500]
2005-01-31 15:56:52: DEBUG: sockname 192.168.2.5[500]
2005-01-31 15:56:52: DEBUG: send packet from 192.168.2.5[500]
2005-01-31 15:56:52: DEBUG: send packet to 192.168.2.3[500]
2005-01-31 15:56:52: DEBUG: src4 192.168.2.5[500]
2005-01-31 15:56:52: DEBUG: dst4 192.168.2.3[500]
2005-01-31 15:56:52: DEBUG: 1 times of 84 bytes message will be sent to 192.168.2.5[500]
2005-01-31 15:56:52: DEBUG:
1b3a78e3 adfafb1d c0e4d647 591c43f6 08100501 c526736e 00000054 acc30f7e
33aa64d5 60b46418 f70cc8f7 18e13f5f 2f992c8e 98fb1326 a9944a07 92f6e1af
e61015e8 3a323d1d caab1e48 9f28ddb4 d437e77a
2005-01-31 15:56:52: DEBUG: sendto Information notify.
2005-01-31 15:56:52: INFO: ISAKMP-SA established 192.168.2.5[500]-192.168.2.3[500] spi:1b3a78e3adfafb1d:c0e4d647591c43f6
2005-01-31 15:56:52: DEBUG: ===
2005-01-31 15:56:52: DEBUG: ===
2005-01-31 15:56:52: DEBUG: 84 bytes message received from 192.168.2.3[500] to 192.168.2.5[500]
2005-01-31 15:56:52: DEBUG:
1b3a78e3 adfafb1d c0e4d647 591c43f6 08100501 d9b420b1 00000054 0b062d5f
65c48bb1 f1f97d55 7a63f3d2 b1f3ce52 08e18c9d 046a9522 f17660de 412b67f8
6fb2edca 729bc018 c252ecb1 c5f19ec7 155d9b78
2005-01-31 15:56:52: DEBUG: receive Information.
2005-01-31 15:56:52: DEBUG: compute IV for phase2
2005-01-31 15:56:52: DEBUG: phase1 last IV:
2005-01-31 15:56:52: DEBUG:
d0b3dc22 1d31f2d0 d9b420b1
2005-01-31 15:56:52: DEBUG: hash(sha1)
2005-01-31 15:56:52: DEBUG: encryption(3des)
2005-01-31 15:56:52: DEBUG: phase2 IV computed:
2005-01-31 15:56:52: DEBUG:
0a67a66c d95a02d0
2005-01-31 15:56:52: DEBUG: begin decryption.
2005-01-31 15:56:52: DEBUG: encryption(3des)
2005-01-31 15:56:52: DEBUG: IV was saved for next processing:
2005-01-31 15:56:52: DEBUG:
c5f19ec7 155d9b78
2005-01-31 15:56:52: DEBUG: encryption(3des)
2005-01-31 15:56:52: DEBUG: with key:
2005-01-31 15:56:52: DEBUG:
5a7c9253 3da7ec0c a029a28f 5d4bfbbb d0730ef7 5b24dc57
2005-01-31 15:56:52: DEBUG: decrypted payload by IV:
2005-01-31 15:56:52: DEBUG:
0a67a66c d95a02d0
2005-01-31 15:56:52: DEBUG: decrypted payload, but not trimed.
2005-01-31 15:56:52: DEBUG:
0b000018 94d84a48 99b0dc57 96900dd9 cf0da364 ef1fada0 0000001c 00000001
01106002 1b3a78e3 adfafb1d c0e4d647 591c43f6 d8c0e303
2005-01-31 15:56:52: DEBUG: padding len=4
2005-01-31 15:56:52: DEBUG: skip to trim padding.
2005-01-31 15:56:52: DEBUG: decrypted.
2005-01-31 15:56:52: DEBUG:
1b3a78e3 adfafb1d c0e4d647 591c43f6 08100501 d9b420b1 00000054 0b000018
94d84a48 99b0dc57 96900dd9 cf0da364 ef1fada0 0000001c 00000001 01106002
1b3a78e3 adfafb1d c0e4d647 591c43f6 d8c0e303
2005-01-31 15:56:52: DEBUG: HASH with:
2005-01-31 15:56:52: DEBUG:
d9b420b1 0000001c 00000001 01106002 1b3a78e3 adfafb1d c0e4d647 591c43f6
2005-01-31 15:56:52: DEBUG: hmac(hmac_sha1)
2005-01-31 15:56:52: DEBUG: HASH computed:
2005-01-31 15:56:52: DEBUG:
94d84a48 99b0dc57 96900dd9 cf0da364 ef1fada0
2005-01-31 15:56:52: DEBUG: hash validated.
2005-01-31 15:56:52: DEBUG: begin.
2005-01-31 15:56:52: DEBUG: seen nptype=8(hash)
2005-01-31 15:56:52: DEBUG: seen nptype=11(notify)
2005-01-31 15:56:52: DEBUG: succeed.
2005-01-31 15:56:52: DEBUG: call pfkey_send_dump
andi: libipsec/pfkey.c, pfkey_setsadbmsg: (p->type: 10, p->sadb_msg_satype: 0, seq: 0)
andi: libipsec/pfkey.c, pfkey_check: start (msg->sadb_msg_satype: 10)
2005-01-31 15:56:52: DEBUG: notification message 24578:INITIAL-CONTACT, doi=1 proto_id=1 spi=1b3a78e3adfafb1d c0e4d647591c43f6 (size=16).
2005-01-31 15:56:53: DEBUG: ===
2005-01-31 15:56:53: DEBUG: 300 bytes message received from 192.168.2.3[500] to 192.168.2.5[500]
2005-01-31 15:56:53: DEBUG:
1b3a78e3 adfafb1d c0e4d647 591c43f6 08102001 f165fca7 0000012c dcfeb0b2
e0b2eccd ea3f08ad 69fe90b4 8bd46e67 9879b11f e767fd68 635c7608 b0479c72
e61639f9 1dbdeb22 38e0764e f781131b 7cf18203 24888306 9bb1ed29 16a9d44f
573124d8 f45ab587 982f0184 89d26499 8312d6cf 7383357e a592a161 f53c9ec6
6befbcf8 a7ea3cc2 79b54188 c013c058 56064703 ab6bf3b3 d88dcf8d 585acba2
999b4d38 cf28dc13 001eee0d 87ef22e4 2af56a81 be66df06 da579520 a1438911
a484cf3c 84f08206 76b16b3e ef272d4a 356ee6c1 57eab6a7 bb50bde2 ee149222
75219866 0beca2c9 42be153c 7e45ed2f 8a722ab5 6d43377f 08520ace 3a87a070
40920c00 a6578bf9 a6ba7809 6334d3fa 20666cc6 5f6d88b1 424cec6d f2559408
f176b3b7 f0e213b8 d6423ed8
2005-01-31 15:56:53: INFO: andi: in isakmp.c, isakmp_ph2begin_r: iph2->seq 369749501
2005-01-31 15:56:53: DEBUG: compute IV for phase2
2005-01-31 15:56:53: DEBUG: phase1 last IV:
2005-01-31 15:56:53: DEBUG:
d0b3dc22 1d31f2d0 f165fca7
2005-01-31 15:56:53: DEBUG: hash(sha1)
2005-01-31 15:56:53: DEBUG: encryption(3des)
2005-01-31 15:56:53: DEBUG: phase2 IV computed:
2005-01-31 15:56:53: DEBUG:
85f7a521 c958f031
2005-01-31 15:56:53: DEBUG: ===
2005-01-31 15:56:53: INFO: respond new phase 2 negotiation: 192.168.2.5[0]<=>192.168.2.3[0]
2005-01-31 15:56:53: DEBUG: begin decryption.
2005-01-31 15:56:53: DEBUG: encryption(3des)
2005-01-31 15:56:53: DEBUG: IV was saved for next processing:
2005-01-31 15:56:53: DEBUG:
f0e213b8 d6423ed8
2005-01-31 15:56:53: DEBUG: encryption(3des)
2005-01-31 15:56:53: DEBUG: with key:
2005-01-31 15:56:53: DEBUG:
5a7c9253 3da7ec0c a029a28f 5d4bfbbb d0730ef7 5b24dc57
2005-01-31 15:56:53: DEBUG: decrypted payload by IV:
2005-01-31 15:56:53: DEBUG:
85f7a521 c958f031
2005-01-31 15:56:53: DEBUG: decrypted payload, but not trimed.
2005-01-31 15:56:53: DEBUG:
01000018 17618673 472d64d3 bfc732ce 2b439a02 edfda95d 0a00005c 00000001
00000001 02000028 01020401 00fea865 0000001c 01030000 80010001 80020e10
80040002 80050002 80030002 00000028 01030401 06aff78a 0000001c 01030000
80010001 80020e10 80040002 80050002 80030002 04000014 c7d64915 bdd7f74e
89c2ca14 e9b1ddb5 00000084 416fb889 f849ba95 60f85d54 7ac2cee5 d84b7c30
0e318740 b0ae8f43 e64168ae 82498bb9 1e87fb24 cce327a2 8932a0a4 60fae7cd
fff242cb 115df7f2 4ff5e26a 2eddd093 089d2f4a a0664b60 c81b0dfe adf8934b
bad975a1 39801e4f 19dd64a6 e5cf684f 4fab2a8e fcb359e2 14c9ba33 6b547e53
b202a193 0c045aed 00557972 809ddf03
2005-01-31 15:56:53: DEBUG: padding len=4
2005-01-31 15:56:53: DEBUG: skip to trim padding.
2005-01-31 15:56:53: DEBUG: decrypted.
2005-01-31 15:56:53: DEBUG:
1b3a78e3 adfafb1d c0e4d647 591c43f6 08102001 f165fca7 0000012c 01000018
17618673 472d64d3 bfc732ce 2b439a02 edfda95d 0a00005c 00000001 00000001
02000028 01020401 00fea865 0000001c 01030000 80010001 80020e10 80040002
80050002 80030002 00000028 01030401 06aff78a 0000001c 01030000 80010001
80020e10 80040002 80050002 80030002 04000014 c7d64915 bdd7f74e 89c2ca14
e9b1ddb5 00000084 416fb889 f849ba95 60f85d54 7ac2cee5 d84b7c30 0e318740
b0ae8f43 e64168ae 82498bb9 1e87fb24 cce327a2 8932a0a4 60fae7cd fff242cb
115df7f2 4ff5e26a 2eddd093 089d2f4a a0664b60 c81b0dfe adf8934b bad975a1
39801e4f 19dd64a6 e5cf684f 4fab2a8e fcb359e2 14c9ba33 6b547e53 b202a193
0c045aed 00557972 809ddf03
2005-01-31 15:56:53: DEBUG: begin.
2005-01-31 15:56:53: DEBUG: seen nptype=8(hash)
2005-01-31 15:56:53: DEBUG: seen nptype=1(sa)
2005-01-31 15:56:53: DEBUG: seen nptype=10(nonce)
2005-01-31 15:56:53: DEBUG: seen nptype=4(ke)
2005-01-31 15:56:53: DEBUG: succeed.
2005-01-31 15:56:53: DEBUG: HASH(1) validate:2005-01-31 15:56:53: DEBUG:
17618673 472d64d3 bfc732ce 2b439a02 edfda95d
2005-01-31 15:56:53: DEBUG: HASH with:
2005-01-31 15:56:53: DEBUG:
f165fca7 0a00005c 00000001 00000001 02000028 01020401 00fea865 0000001c
01030000 80010001 80020e10 80040002 80050002 80030002 00000028 01030401
06aff78a 0000001c 01030000 80010001 80020e10 80040002 80050002 80030002
04000014 c7d64915 bdd7f74e 89c2ca14 e9b1ddb5 00000084 416fb889 f849ba95
60f85d54 7ac2cee5 d84b7c30 0e318740 b0ae8f43 e64168ae 82498bb9 1e87fb24
cce327a2 8932a0a4 60fae7cd fff242cb 115df7f2 4ff5e26a 2eddd093 089d2f4a
a0664b60 c81b0dfe adf8934b bad975a1 39801e4f 19dd64a6 e5cf684f 4fab2a8e
fcb359e2 14c9ba33 6b547e53 b202a193 0c045aed 00557972
2005-01-31 15:56:53: DEBUG: hmac(hmac_sha1)
2005-01-31 15:56:53: DEBUG: HASH computed:
2005-01-31 15:56:53: DEBUG:
17618673 472d64d3 bfc732ce 2b439a02 edfda95d
2005-01-31 15:56:53: DEBUG: anonymous sainfo selected.
2005-01-31 15:56:53: DEBUG: get sa info: anonymous
2005-01-31 15:56:53: DEBUG: get a destination address of SP index from phase1 address due to no ID payloads found OR because ID type is not address.
2005-01-31 15:56:53: DEBUG: get a source address of SP index from phase1 address due to no ID payloads found OR because ID type is not address.
2005-01-31 15:56:53: DEBUG: get a src address from ID payload 192.168.2.3[0] prefixlen=32 ul_proto=0
2005-01-31 15:56:53: DEBUG: get dst address from ID payload 192.168.2.5[0] prefixlen=32 ul_proto=0
2005-01-31 15:56:53: DEBUG: sub:0xbfe8afc0: 192.168.2.3/32[0] 192.168.2.5/32[0] proto=any dir=in
2005-01-31 15:56:53: DEBUG: db: 0x9192650: 192.168.2.3/32[0] 192.168.2.5/32[0] proto=any dir=in
2005-01-31 15:56:53: DEBUG: 0xbfe8afc0 masked with /32: 192.168.2.3[0]
2005-01-31 15:56:53: DEBUG: 0x9192650 masked with /32: 192.168.2.3[0]
2005-01-31 15:56:53: DEBUG: 0xbfe8afc0 masked with /32: 192.168.2.5[0]
2005-01-31 15:56:53: DEBUG: 0x9192650 masked with /32: 192.168.2.5[0]
2005-01-31 15:56:53: DEBUG: sub:0xbfe8afc0: 192.168.2.5/32[0] 192.168.2.3/32[0] proto=any dir=out
2005-01-31 15:56:53: DEBUG: db: 0x9192650: 192.168.2.3/32[0] 192.168.2.5/32[0] proto=any dir=in
2005-01-31 15:56:53: DEBUG: sub:0xbfe8afc0: 192.168.2.5/32[0] 192.168.2.3/32[0] proto=any dir=out
2005-01-31 15:56:53: DEBUG: db: 0x91929a8: 192.168.2.5/32[0] 192.168.2.3/32[0] proto=any dir=out
2005-01-31 15:56:53: DEBUG: 0xbfe8afc0 masked with /32: 192.168.2.5[0]
2005-01-31 15:56:53: DEBUG: 0x91929a8 masked with /32: 192.168.2.5[0]
2005-01-31 15:56:53: DEBUG: 0xbfe8afc0 masked with /32: 192.168.2.3[0]
2005-01-31 15:56:53: DEBUG: 0x91929a8 masked with /32: 192.168.2.3[0]
2005-01-31 15:56:53: DEBUG: suitable SP found:192.168.2.5/32[0] 192.168.2.3/32[0] proto=any dir=out
2005-01-31 15:56:53: DEBUG:  (proto_id=AH spisize=4 spi=00000000 spi_p=00000000 encmode=Transport reqid=0:0)
2005-01-31 15:56:53: DEBUG:   (trns_id=SHA authtype=hmac-sha)
2005-01-31 15:56:53: DEBUG:  (proto_id=ESP spisize=4 spi=00000000 spi_p=00000000 encmode=Transport reqid=0:0)
2005-01-31 15:56:53: DEBUG:   (trns_id=3DES encklen=0 authtype=hmac-sha)
2005-01-31 15:56:53: DEBUG: total SA len=88
2005-01-31 15:56:53: DEBUG:
00000001 00000001 02000028 01020401 00fea865 0000001c 01030000 80010001
80020e10 80040002 80050002 80030002 00000028 01030401 06aff78a 0000001c
01030000 80010001 80020e10 80040002 80050002 80030002
2005-01-31 15:56:53: DEBUG: begin.
2005-01-31 15:56:53: DEBUG: seen nptype=2(prop)
2005-01-31 15:56:53: DEBUG: seen nptype=2(prop)
2005-01-31 15:56:53: DEBUG: succeed.
2005-01-31 15:56:53: DEBUG: proposal #1 len=40
2005-01-31 15:56:53: DEBUG: begin.
2005-01-31 15:56:53: DEBUG: seen nptype=3(trns)
2005-01-31 15:56:53: DEBUG: succeed.
2005-01-31 15:56:53: DEBUG: transform #1 len=28
2005-01-31 15:56:53: DEBUG: type=SA Life Type, flag=0x8000, lorv=seconds
2005-01-31 15:56:53: DEBUG: type=SA Life Duration, flag=0x8000, lorv=3600
2005-01-31 15:56:53: DEBUG: life duration was in TLV.
2005-01-31 15:56:53: DEBUG: type=Encryption Mode, flag=0x8000, lorv=Transport
2005-01-31 15:56:53: DEBUG: type=Authentication Algorithm, flag=0x8000, lorv=hmac-sha
2005-01-31 15:56:53: DEBUG: type=Group Description, flag=0x8000, lorv=2
2005-01-31 15:56:53: DEBUG: hmac(modp1024)
2005-01-31 15:56:53: DEBUG: proposal #1 len=40
2005-01-31 15:56:53: DEBUG: begin.
2005-01-31 15:56:53: DEBUG: seen nptype=3(trns)
2005-01-31 15:56:53: DEBUG: succeed.
2005-01-31 15:56:53: DEBUG: transform #1 len=28
2005-01-31 15:56:53: DEBUG: type=SA Life Type, flag=0x8000, lorv=seconds
2005-01-31 15:56:53: DEBUG: type=SA Life Duration, flag=0x8000, lorv=3600
2005-01-31 15:56:53: DEBUG: life duration was in TLV.
2005-01-31 15:56:53: DEBUG: type=Encryption Mode, flag=0x8000, lorv=Transport
2005-01-31 15:56:53: DEBUG: type=Authentication Algorithm, flag=0x8000, lorv=hmac-sha
2005-01-31 15:56:53: DEBUG: type=Group Description, flag=0x8000, lorv=2
2005-01-31 15:56:53: DEBUG: hmac(modp1024)
2005-01-31 15:56:53: DEBUG: pair 1:
2005-01-31 15:56:53: DEBUG:  0x91946a0: next=0x91946b8 tnext=(nil)
2005-01-31 15:56:53: DEBUG:   0x91946b8: next=(nil) tnext=(nil)
2005-01-31 15:56:53: DEBUG: proposal #1: 2 transform
2005-01-31 15:56:53: DEBUG: begin compare proposals.
2005-01-31 15:56:53: DEBUG: pair[1]: 0x91946a0
2005-01-31 15:56:53: DEBUG:  0x91946a0: next=0x91946b8 tnext=(nil)
2005-01-31 15:56:53: DEBUG:   0x91946b8: next=(nil) tnext=(nil)
2005-01-31 15:56:53: DEBUG: prop#=1 prot-id=AH spi-size=4 #trns=1 trns#=1 trns-id=SHA
2005-01-31 15:56:53: DEBUG: type=SA Life Type, flag=0x8000, lorv=seconds
2005-01-31 15:56:53: DEBUG: type=SA Life Duration, flag=0x8000, lorv=3600
2005-01-31 15:56:53: DEBUG: type=Encryption Mode, flag=0x8000, lorv=Transport
2005-01-31 15:56:53: DEBUG: type=Authentication Algorithm, flag=0x8000, lorv=hmac-sha
2005-01-31 15:56:53: DEBUG: type=Group Description, flag=0x8000, lorv=2
2005-01-31 15:56:53: DEBUG: prop#=1 prot-id=ESP spi-size=4 #trns=1 trns#=1 trns-id=3DES
2005-01-31 15:56:53: DEBUG: type=SA Life Type, flag=0x8000, lorv=seconds
2005-01-31 15:56:53: DEBUG: type=SA Life Duration, flag=0x8000, lorv=3600
2005-01-31 15:56:53: DEBUG: type=Encryption Mode, flag=0x8000, lorv=Transport
2005-01-31 15:56:53: DEBUG: type=Authentication Algorithm, flag=0x8000, lorv=hmac-sha
2005-01-31 15:56:53: DEBUG: type=Group Description, flag=0x8000, lorv=2
2005-01-31 15:56:53: DEBUG: peer's single bundle:
2005-01-31 15:56:53: DEBUG:  (proto_id=AH spisize=4 spi=00fea865 spi_p=00000000 encmode=Transport reqid=0:0)
2005-01-31 15:56:53: DEBUG:   (trns_id=SHA authtype=hmac-sha)
2005-01-31 15:56:53: DEBUG:  (proto_id=ESP spisize=4 spi=06aff78a spi_p=00000000 encmode=Transport reqid=0:0)
2005-01-31 15:56:53: DEBUG:   (trns_id=3DES encklen=0 authtype=hmac-sha)
2005-01-31 15:56:53: DEBUG: my single bundle:
2005-01-31 15:56:53: DEBUG:  (proto_id=AH spisize=4 spi=00000000 spi_p=00000000 encmode=Transport reqid=0:0)
2005-01-31 15:56:53: DEBUG:   (trns_id=SHA authtype=hmac-sha)
2005-01-31 15:56:53: DEBUG:  (proto_id=ESP spisize=4 spi=00000000 spi_p=00000000 encmode=Transport reqid=0:0)
2005-01-31 15:56:53: DEBUG:   (trns_id=3DES encklen=0 authtype=hmac-sha)
2005-01-31 15:56:53: DEBUG: matched
2005-01-31 15:56:53: DEBUG: ===
2005-01-31 15:56:53: DEBUG: andi: pfkey.c, pfkey_send_getspi (pr->proto_id: 2,iph2->seq: 369749501)
andi: libipsec/pfkey.c, pfkey_send_getspi: (satype: 2, seq: 369749501)
andi: libipsec/pfkey.c, pfkey_setsadbmsg: (p->type: 1, p->sadb_msg_satype: 2, seq: 369749501)
2005-01-31 15:56:53: DEBUG: pfkey GETSPI sent: AH/Transport 192.168.2.3->192.168.2.5
2005-01-31 15:56:53: DEBUG: andi: pfkey.c, pfkey_send_getspi (pr->proto_id: 3,iph2->seq: 369749501)
andi: libipsec/pfkey.c, pfkey_send_getspi: (satype: 3, seq: 369749501)
andi: libipsec/pfkey.c, pfkey_setsadbmsg: (p->type: 1, p->sadb_msg_satype: 3, seq: 369749501)
2005-01-31 15:56:53: DEBUG: pfkey GETSPI sent: ESP/Transport 192.168.2.3->192.168.2.5
2005-01-31 15:56:53: DEBUG: pfkey getspi sent.
2005-01-31 15:56:53: DEBUG: get pfkey GETSPI message
andi: libipsec/pfkey.c, pfkey_check: start (msg->sadb_msg_satype: 1)
2005-01-31 15:56:53: DEBUG: andi: pfkey.c, pk_recvgetspi: msg->sadb_msg_seq 369749501, msg->sadb_msg_type: GETSPI .
2005-01-31 15:56:53: DEBUG: pfkey GETSPI succeeded: AH/Transport 192.168.2.3->192.168.2.5 spi=129077146(0x7b18f9a)
2005-01-31 15:56:53: DEBUG: get pfkey GETSPI message
andi: libipsec/pfkey.c, pfkey_check: start (msg->sadb_msg_satype: 1)
2005-01-31 15:56:53: DEBUG: andi: pfkey.c, pk_recvgetspi: msg->sadb_msg_seq 369749501, msg->sadb_msg_type: GETSPI .
2005-01-31 15:56:53: DEBUG: pfkey GETSPI succeeded: ESP/Transport 192.168.2.3->192.168.2.5 spi=219187533(0xd10894d)
2005-01-31 15:56:53: DEBUG: total SA len=88
2005-01-31 15:56:53: DEBUG:
00000001 00000001 02000028 01020401 00000000 0000001c 01030000 80010001
80020e10 80040002 80050002 80030002 00000028 01030401 00000000 0000001c
01030000 80010001 80020e10 80040002 80050002 80030002
2005-01-31 15:56:53: DEBUG: begin.
2005-01-31 15:56:53: DEBUG: seen nptype=2(prop)
2005-01-31 15:56:53: DEBUG: seen nptype=2(prop)
2005-01-31 15:56:53: DEBUG: succeed.
2005-01-31 15:56:53: DEBUG: proposal #1 len=40
2005-01-31 15:56:53: DEBUG: begin.
2005-01-31 15:56:53: DEBUG: seen nptype=3(trns)
2005-01-31 15:56:53: DEBUG: succeed.
2005-01-31 15:56:53: DEBUG: transform #1 len=28
2005-01-31 15:56:53: DEBUG: type=SA Life Type, flag=0x8000, lorv=seconds
2005-01-31 15:56:53: DEBUG: type=SA Life Duration, flag=0x8000, lorv=3600
2005-01-31 15:56:53: DEBUG: life duration was in TLV.
2005-01-31 15:56:53: DEBUG: type=Encryption Mode, flag=0x8000, lorv=Transport
2005-01-31 15:56:53: DEBUG: type=Authentication Algorithm, flag=0x8000, lorv=hmac-sha
2005-01-31 15:56:53: DEBUG: type=Group Description, flag=0x8000, lorv=2
2005-01-31 15:56:53: DEBUG: hmac(modp1024)
2005-01-31 15:56:53: DEBUG: proposal #1 len=40
2005-01-31 15:56:53: DEBUG: begin.
2005-01-31 15:56:53: DEBUG: seen nptype=3(trns)
2005-01-31 15:56:53: DEBUG: succeed.
2005-01-31 15:56:53: DEBUG: transform #1 len=28
2005-01-31 15:56:53: DEBUG: type=SA Life Type, flag=0x8000, lorv=seconds
2005-01-31 15:56:53: DEBUG: type=SA Life Duration, flag=0x8000, lorv=3600
2005-01-31 15:56:53: DEBUG: life duration was in TLV.
2005-01-31 15:56:53: DEBUG: type=Encryption Mode, flag=0x8000, lorv=Transport
2005-01-31 15:56:53: DEBUG: type=Authentication Algorithm, flag=0x8000, lorv=hmac-sha
2005-01-31 15:56:53: DEBUG: type=Group Description, flag=0x8000, lorv=2
2005-01-31 15:56:53: DEBUG: hmac(modp1024)
2005-01-31 15:56:53: DEBUG: pair 1:
2005-01-31 15:56:53: DEBUG:  0x9193f68: next=0x9193c38 tnext=(nil)
2005-01-31 15:56:53: DEBUG:   0x9193c38: next=(nil) tnext=(nil)
2005-01-31 15:56:53: DEBUG: proposal #1: 2 transform
2005-01-31 15:56:53: DEBUG: hmac(modp1024)
2005-01-31 15:56:54: DEBUG: compute DH's private.
2005-01-31 15:56:54: DEBUG:
61ad1a7c 415cc7ca c6b10f8f a509fd30 fc25d6de e2dc3228 3f49513d 213e6d1d
6974d149 87d7ec4a 5d94e7ae c3222132 f9ec891e e48e8e69 9ba1a68d 7cb89355
57942666 093c2d08 1fe48b36 ca5fdb07 fa41c14d b3e1cca7 e59c9dd5 52d4300e
9929bf2d 5d0d8c06 90134e8b 3f8900dd 5c5bc152 aa165c2e d9386aec c274189e
2005-01-31 15:56:54: DEBUG: compute DH's public.
2005-01-31 15:56:54: DEBUG:
1a9a548f 5cb12fc5 349c1372 6d2cc511 51029530 0e739921 f0d6371c 97075f8f
04aa195c 446f788d 5856a2fb 85e21369 ea0bbf44 a2aeea15 f9138f7b ab9a303f
861da44f 6d8b3599 bacac90f ac7ae542 5c32765f fb8b26aa b0392050 7059cae9
d360eac8 4318e7d1 8beda674 a51bc003 559a4854 cdbdf9e7 66338448 1c01038f
2005-01-31 15:56:54: DEBUG: add payload of len 88, next type 10
2005-01-31 15:56:54: DEBUG: add payload of len 16, next type 4
2005-01-31 15:56:54: DEBUG: add payload of len 128, next type 0
2005-01-31 15:56:54: DEBUG: HASH with:
2005-01-31 15:56:54: DEBUG:
f165fca7 c7d64915 bdd7f74e 89c2ca14 e9b1ddb5 0a00005c 00000001 00000001
02000028 01020401 07b18f9a 0000001c 01030000 80010001 80020e10 80040002
80050002 80030002 00000028 01030401 0d10894d 0000001c 01030000 80010001
80020e10 80040002 80050002 80030002 04000014 d298eaa0 a8d2b56e 564d817d
816323c8 00000084 1a9a548f 5cb12fc5 349c1372 6d2cc511 51029530 0e739921
f0d6371c 97075f8f 04aa195c 446f788d 5856a2fb 85e21369 ea0bbf44 a2aeea15
f9138f7b ab9a303f 861da44f 6d8b3599 bacac90f ac7ae542 5c32765f fb8b26aa
b0392050 7059cae9 d360eac8 4318e7d1 8beda674 a51bc003 559a4854 cdbdf9e7
66338448 1c01038f
2005-01-31 15:56:54: DEBUG: hmac(hmac_sha1)
2005-01-31 15:56:54: DEBUG: HASH computed:
2005-01-31 15:56:54: DEBUG:
1c2c3697 3fb6aa73 f0587484 9093486c e94d5f1a
2005-01-31 15:56:54: DEBUG: add payload of len 20, next type 1
2005-01-31 15:56:54: DEBUG: begin encryption.
2005-01-31 15:56:54: DEBUG: encryption(3des)
2005-01-31 15:56:54: DEBUG: pad length = 4
2005-01-31 15:56:54: DEBUG:
01000018 1c2c3697 3fb6aa73 f0587484 9093486c e94d5f1a 0a00005c 00000001
00000001 02000028 01020401 07b18f9a 0000001c 01030000 80010001 80020e10
80040002 80050002 80030002 00000028 01030401 0d10894d 0000001c 01030000
80010001 80020e10 80040002 80050002 80030002 04000014 d298eaa0 a8d2b56e
564d817d 816323c8 00000084 1a9a548f 5cb12fc5 349c1372 6d2cc511 51029530
0e739921 f0d6371c 97075f8f 04aa195c 446f788d 5856a2fb 85e21369 ea0bbf44
a2aeea15 f9138f7b ab9a303f 861da44f 6d8b3599 bacac90f ac7ae542 5c32765f
fb8b26aa b0392050 7059cae9 d360eac8 4318e7d1 8beda674 a51bc003 559a4854
cdbdf9e7 66338448 1c01038f 80c29e03
2005-01-31 15:56:54: DEBUG: encryption(3des)
2005-01-31 15:56:54: DEBUG: with key:
2005-01-31 15:56:54: DEBUG:
5a7c9253 3da7ec0c a029a28f 5d4bfbbb d0730ef7 5b24dc57
2005-01-31 15:56:54: DEBUG: encrypted payload by IV:
2005-01-31 15:56:54: DEBUG:
f0e213b8 d6423ed8
2005-01-31 15:56:54: DEBUG: save IV for next:
2005-01-31 15:56:54: DEBUG:
8facb279 a73879cc
2005-01-31 15:56:54: DEBUG: encrypted.
2005-01-31 15:56:54: DEBUG: 300 bytes from 192.168.2.5[500] to 192.168.2.3[500]
2005-01-31 15:56:54: DEBUG: sockname 192.168.2.5[500]
2005-01-31 15:56:54: DEBUG: send packet from 192.168.2.5[500]
2005-01-31 15:56:54: DEBUG: send packet to 192.168.2.3[500]
2005-01-31 15:56:54: DEBUG: src4 192.168.2.5[500]
2005-01-31 15:56:54: DEBUG: dst4 192.168.2.3[500]
2005-01-31 15:56:54: DEBUG: 1 times of 300 bytes message will be sent to 192.168.2.5[500]
2005-01-31 15:56:54: DEBUG:
1b3a78e3 adfafb1d c0e4d647 591c43f6 08102001 f165fca7 0000012c c59be1a6
93abf8bf cde86a3a e5e428f7 a00db733 43b4dd3e e97adf5b fa4f2609 978df62c
683dbfd2 cdf45e68 0621eb57 193b98cc 392a1bdc bee50fb1 e7e62fa6 4dd38e2c
8810a16b 54e1fdbc 8a130800 8721f2aa 600b7947 b9533309 3ee0bb33 d06de978
c7c44108 5c06d7ae d88639e4 024eb8aa b9fbf222 2920d647 d7589737 7b8f7232
23a84acc f3a340b8 9536ed1a 7a86ac0b 9bf35505 f101cd99 741ac02d 0ff91283
377fea8f d0ac3ae8 fdef3258 d817c2d3 80e4254a 36f1bc93 a0b3857b aa9e1dc7
8b98d62d 0c208041 d3def06e 1a290fab 567deff4 11ae9f98 dbdb0ec2 e8b61cfe
75a991e9 5429bb2b a3a98e56 be822247 b7d4afac d845f41f 88899909 8131b83e
d9289dca 8facb279 a73879cc
2005-01-31 15:56:54: DEBUG: resend phase2 packet 1b3a78e3adfafb1d:c0e4d647591c43f6:0000f165
2005-01-31 15:56:54: DEBUG: ===
2005-01-31 15:56:54: DEBUG: 60 bytes message received from 192.168.2.3[500] to 192.168.2.5[500]
2005-01-31 15:56:54: DEBUG:
1b3a78e3 adfafb1d c0e4d647 591c43f6 08102001 f165fca7 0000003c 7bffc9a8
da9a42f6 a6188903 a72cd735 d5cc4492 002a4ba7 15839dc3 a87a8972
2005-01-31 15:56:54: DEBUG: begin decryption.
2005-01-31 15:56:54: DEBUG: encryption(3des)
2005-01-31 15:56:54: DEBUG: IV was saved for next processing:
2005-01-31 15:56:54: DEBUG:
15839dc3 a87a8972
2005-01-31 15:56:54: DEBUG: encryption(3des)
2005-01-31 15:56:54: DEBUG: with key:
2005-01-31 15:56:54: DEBUG:
5a7c9253 3da7ec0c a029a28f 5d4bfbbb d0730ef7 5b24dc57
2005-01-31 15:56:54: DEBUG: decrypted payload by IV:
2005-01-31 15:56:54: DEBUG:
8facb279 a73879cc
2005-01-31 15:56:54: DEBUG: decrypted payload, but not trimed.
2005-01-31 15:56:54: DEBUG:
00000018 d3b6e22d 0c973dec 931eeb37 d8ba14e3 4c7102df 95d3e7bd f6faf607
2005-01-31 15:56:54: DEBUG: padding len=8
2005-01-31 15:56:54: DEBUG: skip to trim padding.
2005-01-31 15:56:54: DEBUG: decrypted.
2005-01-31 15:56:54: DEBUG:
1b3a78e3 adfafb1d c0e4d647 591c43f6 08102001 f165fca7 0000003c 00000018
d3b6e22d 0c973dec 931eeb37 d8ba14e3 4c7102df 95d3e7bd f6faf607
2005-01-31 15:56:54: DEBUG: begin.
2005-01-31 15:56:54: DEBUG: seen nptype=8(hash)
2005-01-31 15:56:54: DEBUG: succeed.
2005-01-31 15:56:54: DEBUG: HASH(3) validate:2005-01-31 15:56:54: DEBUG:
d3b6e22d 0c973dec 931eeb37 d8ba14e3 4c7102df
2005-01-31 15:56:54: DEBUG: HASH with:
2005-01-31 15:56:54: DEBUG:
00f165fc a7c7d649 15bdd7f7 4e89c2ca 14e9b1dd b5d298ea a0a8d2b5 6e564d81
7d816323 c8
2005-01-31 15:56:54: DEBUG: hmac(hmac_sha1)
2005-01-31 15:56:54: DEBUG: HASH computed:
2005-01-31 15:56:54: DEBUG:
d3b6e22d 0c973dec 931eeb37 d8ba14e3 4c7102df
2005-01-31 15:56:54: DEBUG: ===
2005-01-31 15:56:54: DEBUG: compute DH's shared.
2005-01-31 15:56:54: DEBUG:
ab12d518 48c49b88 b8b41d82 809e78ce 5324cefe 9392b981 97c8c1dc 972c21f3
37b65750 5f6a4f13 6a042fc6 69024994 dbc37801 37902186 e324ae60 d6c396ac
ac9bbd16 38b30565 48aa3baa bfc3430b 4355151d ac8b5b46 e19264f2 01994fd1
f5e44159 1d9b471c b3764b05 95c28afd 94f29a19 974bf59f b3f8ce9a 3119326c
2005-01-31 15:56:54: DEBUG: KEYMAT compute with
2005-01-31 15:56:54: DEBUG:
ab12d518 48c49b88 b8b41d82 809e78ce 5324cefe 9392b981 97c8c1dc 972c21f3
37b65750 5f6a4f13 6a042fc6 69024994 dbc37801 37902186 e324ae60 d6c396ac
ac9bbd16 38b30565 48aa3baa bfc3430b 4355151d ac8b5b46 e19264f2 01994fd1
f5e44159 1d9b471c b3764b05 95c28afd 94f29a19 974bf59f b3f8ce9a 3119326c
0207b18f 9ac7d649 15bdd7f7 4e89c2ca 14e9b1dd b5d298ea a0a8d2b5 6e564d81
7d816323 c8
2005-01-31 15:56:54: DEBUG: hmac(hmac_sha1)
2005-01-31 15:56:54: DEBUG: encklen=0 authklen=0
2005-01-31 15:56:54: DEBUG: generating 480 bits of key (dupkeymat=3)
2005-01-31 15:56:54: DEBUG: generating K1...K3 for KEYMAT.
2005-01-31 15:56:54: DEBUG: hmac(hmac_sha1)
2005-01-31 15:56:54: DEBUG: hmac(hmac_sha1)
2005-01-31 15:56:54: DEBUG:
3af874ac 08fe556c fddec368 1fb82bf8 e907261e 8ead23f4 ffbcd976 526f0569
7ebaa182 8f5de2ab e9c2c443 444c2847 f44aeb9b d9a16c3c 9c2ae6b8
2005-01-31 15:56:54: DEBUG: KEYMAT compute with
2005-01-31 15:56:54: DEBUG:
ab12d518 48c49b88 b8b41d82 809e78ce 5324cefe 9392b981 97c8c1dc 972c21f3
37b65750 5f6a4f13 6a042fc6 69024994 dbc37801 37902186 e324ae60 d6c396ac
ac9bbd16 38b30565 48aa3baa bfc3430b 4355151d ac8b5b46 e19264f2 01994fd1
f5e44159 1d9b471c b3764b05 95c28afd 94f29a19 974bf59f b3f8ce9a 3119326c
030d1089 4dc7d649 15bdd7f7 4e89c2ca 14e9b1dd b5d298ea a0a8d2b5 6e564d81
7d816323 c8
2005-01-31 15:56:54: DEBUG: hmac(hmac_sha1)
2005-01-31 15:56:54: DEBUG: encryption(3des)
2005-01-31 15:56:54: DEBUG: hmac(hmac_sha1)
2005-01-31 15:56:54: DEBUG: encklen=192 authklen=160
2005-01-31 15:56:54: DEBUG: generating 640 bits of key (dupkeymat=4)
2005-01-31 15:56:54: DEBUG: generating K1...K4 for KEYMAT.
2005-01-31 15:56:54: DEBUG: hmac(hmac_sha1)
2005-01-31 15:56:54: DEBUG: hmac(hmac_sha1)
2005-01-31 15:56:54: DEBUG: hmac(hmac_sha1)
2005-01-31 15:56:54: DEBUG:
71029e05 9f9f7fa9 1dc99080 7cb4a9ee b9bf2792 32deacc8 80596d90 ba7c0543
c1b40d8a f790d58e ccf66f87 653494e8 cbb3f725 c0f119ee f2f1e4e6 83d9e937
0a1fbbfa 40590ee8 8479816c 1ab9321f
2005-01-31 15:56:54: DEBUG: KEYMAT compute with
2005-01-31 15:56:54: DEBUG:
ab12d518 48c49b88 b8b41d82 809e78ce 5324cefe 9392b981 97c8c1dc 972c21f3
37b65750 5f6a4f13 6a042fc6 69024994 dbc37801 37902186 e324ae60 d6c396ac
ac9bbd16 38b30565 48aa3baa bfc3430b 4355151d ac8b5b46 e19264f2 01994fd1
f5e44159 1d9b471c b3764b05 95c28afd 94f29a19 974bf59f b3f8ce9a 3119326c
0200fea8 65c7d649 15bdd7f7 4e89c2ca 14e9b1dd b5d298ea a0a8d2b5 6e564d81
7d816323 c8
2005-01-31 15:56:54: DEBUG: hmac(hmac_sha1)
2005-01-31 15:56:54: DEBUG: encklen=0 authklen=0
2005-01-31 15:56:54: DEBUG: generating 480 bits of key (dupkeymat=3)
2005-01-31 15:56:54: DEBUG: generating K1...K3 for KEYMAT.
2005-01-31 15:56:54: DEBUG: hmac(hmac_sha1)
2005-01-31 15:56:54: DEBUG: hmac(hmac_sha1)
2005-01-31 15:56:54: DEBUG:
d1bc914f 7e79fd37 a72b8c46 a4326199 5ef4009c 72540f34 fba939c2 79232d22
1dada88a edebf394 42a181f6 6929749b d5a02847 7035ef42 50b8f77b
2005-01-31 15:56:54: DEBUG: KEYMAT compute with
2005-01-31 15:56:54: DEBUG:
ab12d518 48c49b88 b8b41d82 809e78ce 5324cefe 9392b981 97c8c1dc 972c21f3
37b65750 5f6a4f13 6a042fc6 69024994 dbc37801 37902186 e324ae60 d6c396ac
ac9bbd16 38b30565 48aa3baa bfc3430b 4355151d ac8b5b46 e19264f2 01994fd1
f5e44159 1d9b471c b3764b05 95c28afd 94f29a19 974bf59f b3f8ce9a 3119326c
0306aff7 8ac7d649 15bdd7f7 4e89c2ca 14e9b1dd b5d298ea a0a8d2b5 6e564d81
7d816323 c8
2005-01-31 15:56:54: DEBUG: hmac(hmac_sha1)
2005-01-31 15:56:54: DEBUG: encryption(3des)
2005-01-31 15:56:54: DEBUG: hmac(hmac_sha1)
2005-01-31 15:56:54: DEBUG: encklen=192 authklen=160
2005-01-31 15:56:54: DEBUG: generating 640 bits of key (dupkeymat=4)
2005-01-31 15:56:54: DEBUG: generating K1...K4 for KEYMAT.
2005-01-31 15:56:54: DEBUG: hmac(hmac_sha1)
2005-01-31 15:56:54: DEBUG: hmac(hmac_sha1)
2005-01-31 15:56:54: DEBUG: hmac(hmac_sha1)
2005-01-31 15:56:54: DEBUG:
ff237a88 c0438bc9 3e19ff2c 4b0c9a2a 2e7797d4 50de0b4e 50f124ac 808c9ec5
cf098100 ff24656f 3faaf2e0 ccc6323a 346d426e 8fba2cc3 b6c4f2e2 24231bf2
c636d43a 689cf0a7 b2d89724 58f43176
2005-01-31 15:56:54: DEBUG: KEYMAT computed.
2005-01-31 15:56:54: DEBUG: call pk_sendupdate
2005-01-31 15:56:54: DEBUG: hmac(hmac_sha1)
2005-01-31 15:56:54: DEBUG: call pfkey_send_update_nat
andi: libipsec/pfkey.c, pfkey_setsadbmsg: (p->type: 2, p->sadb_msg_satype: 2, seq: 369749501)
andi: libipsec/pfkey.c, pfkey_send_x1: (satype: 2, spi 2593108231)
2005-01-31 15:56:54: DEBUG: encryption(3des)
2005-01-31 15:56:54: DEBUG: hmac(hmac_sha1)
2005-01-31 15:56:54: DEBUG: call pfkey_send_update_nat
andi: libipsec/pfkey.c, pfkey_setsadbmsg: (p->type: 2, p->sadb_msg_satype: 3, seq: 369749501)
andi: libipsec/pfkey.c, pfkey_send_x1: (satype: 3, spi 1300828173)
2005-01-31 15:56:54: DEBUG: pfkey update sent.
2005-01-31 15:56:54: DEBUG: andi: pfkey.c, pk_sendadd: start
2005-01-31 15:56:54: DEBUG: hmac(hmac_sha1)
2005-01-31 15:56:54: DEBUG: call pfkey_send_add_nat
andi: libipsec/pfkey.c, pfkey_setsadbmsg: (p->type: 3, p->sadb_msg_satype: 2, seq: 369749501)
andi: libipsec/pfkey.c, pfkey_send_x1: (satype: 2, spi 1705573888)
2005-01-31 15:56:54: DEBUG: encryption(3des)
2005-01-31 15:56:54: DEBUG: hmac(hmac_sha1)
2005-01-31 15:56:54: DEBUG: call pfkey_send_add_nat
andi: libipsec/pfkey.c, pfkey_setsadbmsg: (p->type: 3, p->sadb_msg_satype: 3, seq: 369749501)
andi: libipsec/pfkey.c, pfkey_send_x1: (satype: 3, spi 2331488006)
2005-01-31 15:56:54: DEBUG: andi: pfkey.c, pk_sendadd: ende
2005-01-31 15:56:54: DEBUG: pfkey add sent.
2005-01-31 15:56:54: DEBUG: get pfkey UPDATE message
andi: libipsec/pfkey.c, pfkey_check: start (msg->sadb_msg_satype: 2)
2005-01-31 15:56:54: DEBUG: andi: pfkey.c, pk_recvupdate: start
2005-01-31 15:56:54: DEBUG: andi: in pfkey.c, pk_recvupdate: msg->sadb_msg_seq 369749501, msg->sadb_msg_type: UPDATE
2005-01-31 15:56:54: DEBUG: pfkey UPDATE succeeded: AH/Transport 192.168.2.3->192.168.2.5 spi=129077146(0x7b18f9a)
2005-01-31 15:56:54: INFO: IPsec-SA established: AH/Transport 192.168.2.3->192.168.2.5 spi=129077146(0x7b18f9a)
2005-01-31 15:56:54: DEBUG: get pfkey UPDATE message
andi: libipsec/pfkey.c, pfkey_check: start (msg->sadb_msg_satype: 2)
2005-01-31 15:56:54: DEBUG: andi: pfkey.c, pk_recvupdate: start
2005-01-31 15:56:54: DEBUG: andi: in pfkey.c, pk_recvupdate: msg->sadb_msg_seq 369749501, msg->sadb_msg_type: UPDATE
2005-01-31 15:56:54: DEBUG: pfkey UPDATE succeeded: ESP/Transport 192.168.2.3->192.168.2.5 spi=219187533(0xd10894d)
2005-01-31 15:56:54: INFO: IPsec-SA established: ESP/Transport 192.168.2.3->192.168.2.5 spi=219187533(0xd10894d)
2005-01-31 15:56:54: DEBUG: andi: pfkey.c, pk_recvupdate: ende
2005-01-31 15:56:54: DEBUG: ===
2005-01-31 15:56:54: DEBUG: get pfkey ADD message
andi: libipsec/pfkey.c, pfkey_check: start (msg->sadb_msg_satype: 3)
2005-01-31 15:56:54: DEBUG: andi: in pfkey.c, pk_recvadd: msg->sadb_msg_seq 369749501, msg->sadb_msg_type: ADD
2005-01-31 15:56:54: INFO: IPsec-SA established: AH/Transport 192.168.2.5->192.168.2.3 spi=16689253(0xfea865)
2005-01-31 15:56:54: DEBUG: ===
2005-01-31 15:56:54: DEBUG: get pfkey ADD message
andi: libipsec/pfkey.c, pfkey_check: start (msg->sadb_msg_satype: 3)
2005-01-31 15:56:54: DEBUG: andi: in pfkey.c, pk_recvadd: msg->sadb_msg_seq 369749501, msg->sadb_msg_type: ADD
2005-01-31 15:56:54: INFO: IPsec-SA established: ESP/Transport 192.168.2.5->192.168.2.3 spi=112195466(0x6aff78a)
2005-01-31 15:56:54: DEBUG: ===
2005-01-31 15:57:02: INFO: caught signal 2
andi: libipsec/pfkey.c, pfkey_setsadbmsg: (p->type: 9, p->sadb_msg_satype: 0, seq: 0)
2005-01-31 15:57:02: DEBUG: get pfkey FLUSH message
andi: libipsec/pfkey.c, pfkey_check: start (msg->sadb_msg_satype: 9)
2005-01-31 15:57:02: DEBUG: compute IV for phase2
2005-01-31 15:57:02: DEBUG: phase1 last IV:
2005-01-31 15:57:02: DEBUG:
d0b3dc22 1d31f2d0 f6cf0393
2005-01-31 15:57:02: DEBUG: hash(sha1)
2005-01-31 15:57:02: DEBUG: encryption(3des)
2005-01-31 15:57:02: DEBUG: phase2 IV computed:
2005-01-31 15:57:02: DEBUG:
4c579727 173cfcdf
2005-01-31 15:57:02: DEBUG: HASH with:
2005-01-31 15:57:02: DEBUG:
f6cf0393 00000010 00000001 02040001 07b18f9a
2005-01-31 15:57:02: DEBUG: hmac(hmac_sha1)
2005-01-31 15:57:02: DEBUG: HASH computed:
2005-01-31 15:57:02: DEBUG:
0715e057 78eb3389 9e5ad122 a1437de0 d17af863
2005-01-31 15:57:02: DEBUG: begin encryption.
2005-01-31 15:57:02: DEBUG: encryption(3des)
2005-01-31 15:57:02: DEBUG: pad length = 8
2005-01-31 15:57:02: DEBUG:
0c000018 0715e057 78eb3389 9e5ad122 a1437de0 d17af863 00000010 00000001
02040001 07b18f9a b3e7baec f4a9ef07
2005-01-31 15:57:02: DEBUG: encryption(3des)
2005-01-31 15:57:02: DEBUG: with key:
2005-01-31 15:57:02: DEBUG:
5a7c9253 3da7ec0c a029a28f 5d4bfbbb d0730ef7 5b24dc57
2005-01-31 15:57:02: DEBUG: encrypted payload by IV:
2005-01-31 15:57:02: DEBUG:
4c579727 173cfcdf
2005-01-31 15:57:02: DEBUG: save IV for next:
2005-01-31 15:57:02: DEBUG:
0f1fe112 9212600e
2005-01-31 15:57:02: DEBUG: encrypted.
2005-01-31 15:57:02: DEBUG: 76 bytes from 192.168.2.5[500] to 192.168.2.3[500]
2005-01-31 15:57:02: DEBUG: sockname 192.168.2.5[500]
2005-01-31 15:57:02: DEBUG: send packet from 192.168.2.5[500]
2005-01-31 15:57:02: DEBUG: send packet to 192.168.2.3[500]
2005-01-31 15:57:02: DEBUG: src4 192.168.2.5[500]
2005-01-31 15:57:02: DEBUG: dst4 192.168.2.3[500]
2005-01-31 15:57:02: DEBUG: 1 times of 76 bytes message will be sent to 192.168.2.5[500]
2005-01-31 15:57:02: DEBUG:
1b3a78e3 adfafb1d c0e4d647 591c43f6 08100501 f6cf0393 0000004c bd4fcd13
d7973d7c a9370d65 ed55caef 745583b1 33c4c9ff 541ae249 a7641bde adb4c1bf
319b79f4 0f1fe112 9212600e
2005-01-31 15:57:02: DEBUG: sendto Information delete.
2005-01-31 15:57:02: DEBUG: compute IV for phase2
2005-01-31 15:57:02: DEBUG: phase1 last IV:
2005-01-31 15:57:02: DEBUG:
d0b3dc22 1d31f2d0 c9a50cea
2005-01-31 15:57:02: DEBUG: hash(sha1)
2005-01-31 15:57:02: DEBUG: encryption(3des)
2005-01-31 15:57:02: DEBUG: phase2 IV computed:
2005-01-31 15:57:02: DEBUG:
b55ad535 fe76042b
2005-01-31 15:57:02: DEBUG: HASH with:
2005-01-31 15:57:02: DEBUG:
c9a50cea 00000010 00000001 03040001 0d10894d
2005-01-31 15:57:02: DEBUG: hmac(hmac_sha1)
2005-01-31 15:57:02: DEBUG: HASH computed:
2005-01-31 15:57:02: DEBUG:
be21e06e 14682bdf 5d12beda b6f08dd6 9c5439c2
2005-01-31 15:57:02: DEBUG: begin encryption.
2005-01-31 15:57:02: DEBUG: encryption(3des)
2005-01-31 15:57:02: DEBUG: pad length = 8
2005-01-31 15:57:02: DEBUG:
0c000018 be21e06e 14682bdf 5d12beda b6f08dd6 9c5439c2 00000010 00000001
03040001 0d10894d bf9aa6cd d5a7ac07
2005-01-31 15:57:02: DEBUG: encryption(3des)
2005-01-31 15:57:02: DEBUG: with key:
2005-01-31 15:57:02: DEBUG:
5a7c9253 3da7ec0c a029a28f 5d4bfbbb d0730ef7 5b24dc57
2005-01-31 15:57:02: DEBUG: encrypted payload by IV:
2005-01-31 15:57:02: DEBUG:
b55ad535 fe76042b
2005-01-31 15:57:02: DEBUG: save IV for next:
2005-01-31 15:57:02: DEBUG:
10aedf12 50d5d196
2005-01-31 15:57:02: DEBUG: encrypted.
2005-01-31 15:57:02: DEBUG: 76 bytes from 192.168.2.5[500] to 192.168.2.3[500]
2005-01-31 15:57:02: DEBUG: sockname 192.168.2.5[500]
2005-01-31 15:57:02: DEBUG: send packet from 192.168.2.5[500]
2005-01-31 15:57:02: DEBUG: send packet to 192.168.2.3[500]
2005-01-31 15:57:02: DEBUG: src4 192.168.2.5[500]
2005-01-31 15:57:02: DEBUG: dst4 192.168.2.3[500]
2005-01-31 15:57:02: DEBUG: 1 times of 76 bytes message will be sent to 192.168.2.5[500]
2005-01-31 15:57:02: DEBUG:
1b3a78e3 adfafb1d c0e4d647 591c43f6 08100501 c9a50cea 0000004c 461c5c4d
f2ca3b90 c73807da d84f253e e3acaa86 ec8d0dc2 be1ed5ea 19cc1e63 16ad963f
a9a566e4 10aedf12 50d5d196
2005-01-31 15:57:02: DEBUG: sendto Information delete.
2005-01-31 15:57:02: DEBUG: an undead schedule has been deleted.
2005-01-31 15:57:03: DEBUG: call pfkey_send_dump
andi: libipsec/pfkey.c, pfkey_setsadbmsg: (p->type: 10, p->sadb_msg_satype: 0, seq: 0)
andi: libipsec/pfkey.c, pfkey_check: start (msg->sadb_msg_satype: 10)
2005-01-31 15:57:03: DEBUG: compute IV for phase2
2005-01-31 15:57:03: DEBUG: phase1 last IV:
2005-01-31 15:57:03: DEBUG:
d0b3dc22 1d31f2d0 8e1131ff
2005-01-31 15:57:03: DEBUG: hash(sha1)
2005-01-31 15:57:03: DEBUG: encryption(3des)
2005-01-31 15:57:03: DEBUG: phase2 IV computed:
2005-01-31 15:57:03: DEBUG:
a32d8d7b f61e2114
2005-01-31 15:57:03: DEBUG: HASH with:
2005-01-31 15:57:03: DEBUG:
8e1131ff 0000001c 00000001 01100001 1b3a78e3 adfafb1d c0e4d647 591c43f6
2005-01-31 15:57:03: DEBUG: hmac(hmac_sha1)
2005-01-31 15:57:03: DEBUG: HASH computed:
2005-01-31 15:57:03: DEBUG:
cc70fba0 88f669db 3aa73457 8721f054 42e69e3a
2005-01-31 15:57:03: DEBUG: begin encryption.
2005-01-31 15:57:03: DEBUG: encryption(3des)
2005-01-31 15:57:03: DEBUG: pad length = 4
2005-01-31 15:57:03: DEBUG:
0c000018 cc70fba0 88f669db 3aa73457 8721f054 42e69e3a 0000001c 00000001
01100001 1b3a78e3 adfafb1d c0e4d647 591c43f6 a7aff503
2005-01-31 15:57:03: DEBUG: encryption(3des)
2005-01-31 15:57:03: DEBUG: with key:
2005-01-31 15:57:03: DEBUG:
5a7c9253 3da7ec0c a029a28f 5d4bfbbb d0730ef7 5b24dc57
2005-01-31 15:57:03: DEBUG: encrypted payload by IV:
2005-01-31 15:57:03: DEBUG:
a32d8d7b f61e2114
2005-01-31 15:57:03: DEBUG: save IV for next:
2005-01-31 15:57:03: DEBUG:
0b8f99d8 d092b040
2005-01-31 15:57:03: DEBUG: encrypted.
2005-01-31 15:57:03: DEBUG: 84 bytes from 192.168.2.5[500] to 192.168.2.3[500]
2005-01-31 15:57:03: DEBUG: sockname 192.168.2.5[500]
2005-01-31 15:57:03: DEBUG: send packet from 192.168.2.5[500]
2005-01-31 15:57:03: DEBUG: send packet to 192.168.2.3[500]
2005-01-31 15:57:03: DEBUG: src4 192.168.2.5[500]
2005-01-31 15:57:03: DEBUG: dst4 192.168.2.3[500]
2005-01-31 15:57:03: DEBUG: 1 times of 84 bytes message will be sent to 192.168.2.5[500]
2005-01-31 15:57:03: DEBUG:
1b3a78e3 adfafb1d c0e4d647 591c43f6 08100501 8e1131ff 00000054 fb2707d6
5c326720 9677a767 e8b8e127 8ce26bc4 69ee5837 717bbbed 6d13934a beefc296
1a04179e a9302874 f547249b 0b8f99d8 d092b040
2005-01-31 15:57:03: DEBUG: sendto Information delete.
2005-01-31 15:57:03: DEBUG: an undead schedule has been deleted.
2005-01-31 15:57:03: INFO: racoon shutdown
[root@litiusoft racoon]#

--Boundary-00=_+xk/BkoCfSG/nsz--
