From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: ipsec doesn't route TCP with 4.11 kernel
Date: Wed, 26 Apr 2017 22:01:34 -0700
Message-ID: <CAM_iQpWT5tF5+LpoTP98JNJ=440jEkxHFkn8=jtAsZgondN49A@mail.gmail.com>
References: <CADJev78Cs0VBdagtfU-71pv3HHC5Vq41UXQee856aVbUqEqAYg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Don Bowman <db@donbowman.ca>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CADJev78Cs0VBdagtfU-71pv3HHC5Vq41UXQee856aVbUqEqAYg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(Cc'ing netdev and IPSec maintainers)

On Tue, Apr 25, 2017 at 6:08 PM, Don Bowman <db@donbowman.ca> wrote:
> I'm not sure how to describe this.
>
> 4.11rc2 worked, after that, no.
>
> My ipsec tunnel comes up ok. ICMP works. UDP works. But TCP, the
> sender [which is the ipsec client] does not reach the destination.
>
> Its not a routing rule issue (since ICMP/UDP work).
> Its not a traffic selector just selecting TCP (I think) since ipsec
> status shows just a subnet, no protocol.
>
> Using tcpdump:
> # iptables -t mangle -I PREROUTING -m policy --pol ipsec --dir in -j
> NFLOG --nflog-group 5
> # iptables -t mangle -I POSTROUTING -m policy --pol ipsec --dir out -j
> NFLOG --nflog-group 5
> # tcpdump -s 0 -n -i nflog:5
>
> I see that it thinks it is sending the TCP packet, but the server end
> does not receive.
>
> Does anyone have any suggestion to try?
>
> strongswan is 5.5.1 [on ubuntu 17.04]
> kernel is 4.11.0-041100rc8-generic
>
> My rightsubnet is
> rightsubnet = 192.168.128.0/17,10.0.0.0/8
>
> so no specific protocol selected, the result is:
> CHILD_SA sv{1} established with SPIs c05f1b6c_i 0d58815a_o and TS
> 192.168.130.4/32 === 10.0.0.0/8 192.168.128.0/17
>
> I tried changing charondebug net=3, but i'm not sure how to interpret
> the output:
>
> Apr 25 21:06:34 office charon: 04[NET] received packet: from
> 64.7.137.180[4500] to 172.16.0.8[4500] (80 bytes)
> Apr 25 21:06:34 office charon: 04[ENC] parsed INFORMATIONAL request 4 [ ]
> Apr 25 21:06:34 office charon: 04[ENC] generating INFORMATIONAL response 4 [ ]
> Apr 25 21:06:34 office charon: 04[NET] sending packet: from
> 172.16.0.8[4500] to 64.7.137.180[4500] (80 bytes)
