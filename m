From: Don Bowman <db@donbowman.ca>
Subject: Re: ipsec doesn't route TCP with 4.11 kernel
Date: Thu, 27 Apr 2017 18:15:19 -0400
Message-ID: <CADJev79wjQgYz1+7zngd+6Pc0YtUrCf5=wg9BPwg8mGHAhUxxg@mail.gmail.com>
References: <CADJev78Cs0VBdagtfU-71pv3HHC5Vq41UXQee856aVbUqEqAYg@mail.gmail.com>
 <CAM_iQpWT5tF5+LpoTP98JNJ=440jEkxHFkn8=jtAsZgondN49A@mail.gmail.com> <20170427084238.GX2649@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:32872 "EHLO
        mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754141AbdD0WPV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 18:15:21 -0400
Received: by mail-io0-f170.google.com with SMTP id k87so38407917ioi.0
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2017 15:15:21 -0700 (PDT)
In-Reply-To: <20170427084238.GX2649@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27 April 2017 at 04:42, Steffen Klassert
<steffen.klassert@secunet.com> wrote:
> On Wed, Apr 26, 2017 at 10:01:34PM -0700, Cong Wang wrote:
>> (Cc'ing netdev and IPSec maintainers)
>>
>> On Tue, Apr 25, 2017 at 6:08 PM, Don Bowman <db@donbowman.ca> wrote:

for 'esp' question, i have ' esp = aes256-sha256-modp1536!' is that
what you mean?
its nat-aware tunnel [from my desktop pc to my office]

root@office:~# ip -s x s
src 172.16.0.8 dst 64.7.137.180
        proto esp spi 0x0d588366(223904614) reqid 1(0x00000001) mode tunnel
        replay-window 0 seq 0x00000000 flag af-unspec (0x00100000)
        auth-trunc hmac(sha256)
0x046cafdf19c5d78d1c29165d96a0b9fce1c500029d77be0fe956dce1bf80a86a
(256 bits) 128
        enc cbc(aes)
0x79ff2fbc2178eb468de6ff16612f0603b514a1d1d5f375c67222294463ec7c62
(256 bits)
        encap type espinudp sport 4500 dport 4500 addr 0.0.0.0
        anti-replay context: seq 0x0, oseq 0x28, bitmap 0x00000000
        lifetime config:
          limit: soft (INF)(bytes), hard (INF)(bytes)
          limit: soft (INF)(packets), hard (INF)(packets)
          expire add: soft 42843(sec), hard 43200(sec)
          expire use: soft 0(sec), hard 0(sec)
        lifetime current:
          2986(bytes), 40(packets)
          add 2017-04-27 18:08:12 use 2017-04-27 18:08:12
        stats:
          replay-window 0 replay 0 failed 0
src 64.7.137.180 dst 172.16.0.8
        proto esp spi 0xcd366c03(3442895875) reqid 1(0x00000001) mode tunnel
        replay-window 32 seq 0x00000000 flag af-unspec (0x00100000)
        auth-trunc hmac(sha256)
0x4158741cc971c49417d60165f19ed02249385c7bba808927d4a9e7b45fb30c5b
(256 bits) 128
        enc cbc(aes)
0x77592c79c964787bca5012214b85172b06deb7b3f06aac02e3934dd9ead67c15
(256 bits)
        encap type espinudp sport 4500 dport 4500 addr 0.0.0.0
        anti-replay context: seq 0x27, oseq 0x0, bitmap 0xffffffff
        lifetime config:
          limit: soft (INF)(bytes), hard (INF)(bytes)
          limit: soft (INF)(packets), hard (INF)(packets)
          expire add: soft 42873(sec), hard 43200(sec)
          expire use: soft 0(sec), hard 0(sec)
        lifetime current:
          4501(bytes), 38(packets)
          add 2017-04-27 18:08:12 use 2017-04-27 18:08:12
        stats:
          replay-window 0 replay 0 failed 0


>> >
>> > My ipsec tunnel comes up ok.
>
> When talking about IPsec, I guess you use ESP, right?
 ...

>
> If it is a GRO issue, then it is on the receive side, could you do
> tcpdump on the receiving interface to see what you get there?

I'm not sure what you mean the receiving interface, you mean the
outer, the native interface?
listening on eno1, link-type EN10MB (Ethernet), capture size 262144 bytes
18:11:32.061501 IP 172.16.0.8.3416 > 64.7.137.180.33638: truncated-udplength 0
18:11:32.788091 IP 64.7.137.180.4500 > 172.16.0.8.4500: NONESP-encap:
isakmp: child_sa  inf2
18:11:32.788354 IP 172.16.0.8.4500 > 64.7.137.180.4500: NONESP-encap:
isakmp: child_sa  inf2[IR]
18:11:33.066830 IP 172.16.0.8.3416 > 64.7.137.180.33638: truncated-udplength 0
18:11:35.082839 IP 172.16.0.8.3416 > 64.7.137.180.33638: truncated-udplength 0
18:11:37.807945 IP 64.7.137.180.4500 > 172.16.0.8.4500: NONESP-encap:
isakmp: child_sa  inf2
18:11:37.808300 IP 172.16.0.8.4500 > 64.7.137.180.4500: NONESP-encap:
isakmp: child_sa  inf2[IR]

is what i see there for the 'curl' command that doesn't complete.

>
> What shows /proc/net/xfrm_stat?

root@office:~# cat /proc/net/xfrm_stat
XfrmInError                     0
XfrmInBufferError               0
XfrmInHdrError                  0
XfrmInNoStates                  0
XfrmInStateProtoError           0
XfrmInStateModeError            0
XfrmInStateSeqError             0
XfrmInStateExpired              0
XfrmInStateMismatch             0
XfrmInStateInvalid              0
XfrmInTmplMismatch              0
XfrmInNoPols                    0
XfrmInPolBlock                  0
XfrmInPolError                  0
XfrmOutError                    0
XfrmOutBundleGenError           0
XfrmOutBundleCheckError         0
XfrmOutNoStates                 0
XfrmOutStateProtoError          0
XfrmOutStateModeError           0
XfrmOutStateSeqError            0
XfrmOutStateExpired             0
XfrmOutPolBlock                 0
XfrmOutPolDead                  0
XfrmOutPolError                 0
XfrmFwdHdrError                 0
XfrmOutStateInvalid             0
XfrmAcquireError                0

>
> Can you do 'ip -s x s' to see if the SAs are used?
>
> Do you have INET_ESP_OFFLOAD enabled?
>

CONFIG_INET_ESP=m
CONFIG_INET_ESP_OFFLOAD=m
CONFIG_INET6_ESP=m
CONFIG_INET6_ESP_OFFLOAD=m
CONFIG_NETFILTER_XT_MATCH_ESP=m
CONFIG_IP_VS_PROTO_AH_ESP=y
CONFIG_IP_VS_PROTO_ESP=y


# lsmod |grep esp
esp4                   20480  2
xfrm_algo              16384  5 xfrm_user,esp4,ah4,af_key,xfrm_ipcomp
