From: Erik Grinaker <erik@bengler.no>
Subject: Re: TCP connection issues against Amazon S3
Date: Wed, 7 Jan 2015 13:31:28 +0000
Message-ID: <34CE0233-F881-4F40-B119-AA9D8F7D500F@bengler.no>
References: <5DCDADEF-FF9C-4844-8A2C-62E2D3B3B8CE@bengler.no> <1420560253.32621.20.camel@edumazet-glaptop2.roam.corp.google.com> <D5C36777-4461-4B8D-B6C4-38B4276F42DC@bengler.no> <1420564837.32621.30.camel@edumazet-glaptop2.roam.corp.google.com> <8C4F7938-DCA1-46F5-A3C9-7DF62511DEE7@bengler.no> <CAK6E8=d5Z0W5sSAdeEcecKbqjj_UwGw4949=a20fetFpLVKwwA@mail.gmail.com> <03FC652E-AA01-42C7-BD52-019B6D922A9C@bengler.no> <CAK6E8=cP0BFUob5MVj9M0hC0efgRnUY=JMUPKee+v-4TLvHBgg@mail.gmail.com> <76DC89D1-CFCE-44B7-994E-4349FEEDEFA6@bengler.no> <1420575216.5947.12.camel@edumazet-glaptop2.roam.corp.google.com> <4DA8529D-4EEC-42DA-89B0-DC7746DB2B10@bengler.no> <3F608393-E5F1-4647-81BF-C6C740100934@bengler.no> <CAK6E8=cf7cROQ0SON0BihkbOsBB+-sLAbexxgt4_xD+Auqev3Q@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 8.1 \(1993\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAK6E8=cf7cROQ0SON0BihkbOsBB+-sLAbexxgt4_xD+Auqev3Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06 Jan 2015, at 22:00, Yuchung Cheng <ycheng@google.com> wrote:
> On Tue, Jan 6, 2015 at 1:04 PM, Erik Grinaker <erik@bengler.no> wrote=
:
>>=20
>>> On 06 Jan 2015, at 20:26, Erik Grinaker <erik@bengler.no> wrote:
>> This still doesn=E2=80=99t explain why it works with older kernels, =
but not newer ones. I=E2=80=99m thinking it=E2=80=99s
> probably some minor change, which gets amplified by the lack of SACKs
> on the loadbalancer. Anyway, I=E2=80=99ll bring it up with Amazon.
> can you post traces with the older kernels?

Here is a dump using 3.11.10 against a non-SACK-enabled loadbalancer:

http://abstrakt.bengler.no/tcp-issues-s3-nosack-3.11.10.pcap.bz2

The transfer shows lots of DUPACKs and retransmits, but this does not s=
eem to have as bad an effect as it did with the failing transfer we saw=
 on newer kernels:

http://abstrakt.bengler.no/tcp-issues-s3-failure.pcap.bz2

One big difference, which Rick touched on earlier, is that the newer ke=
rnels keep sending TCP window updates as it=E2=80=99s going through the=
 retransmits. The older kernel does not do this.
