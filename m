From: "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>
Subject: Re: [PATCH v3 net-next 1/4] tcp: ULP infrastructure
Date: Mon, 26 Jun 2017 15:07:35 +0000
Message-ID: <20170626150740.daohif2peu5eisdc@sasha-lappy>
References: <cover.1497465295.git.davejwatson@fb.com>
 <20170614183714.GA80310@davejwatson-mba.dhcp.thefacebook.com>
 <20170625024258.qoynefxset3cmdla@sasha-lappy>
 <20170626143019.GA6357@davejwatson-mba.dhcp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Ilya Lesokhin <ilyal@mellanox.com>,
        Aviad Yehezkel <aviadye@mellanox.com>,
        Boris Pismenny <borisp@mellanox.com>,
        Liran Liss <liranl@mellanox.com>,
        "Matan Barak" <matanb@mellanox.com>,
        David Miller <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Tom Herbert <tom@herbertland.com>,
        "herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
        "linux-crypto@vger.kernel.org" <linux-crypto@vger.kernel.org>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        "Alexei Starovoitov" <alexei.starovoitov@gmail.com>,
        "nmav@gnutls.org" <nmav@gnutls.org>,
        "fridolin.pokorny@gmail.com" <fridolin.pokorny@gmail.com>
To: Dave Watson <davejwatson@fb.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20170626143019.GA6357@davejwatson-mba.dhcp.thefacebook.com>
Content-Language: en-US
Content-ID: <51F199AA69459D4F9D0C588D5036A5BA@vzwcorp.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 26, 2017 at 07:30:19AM -0700, Dave Watson wrote:
>On 06/25/17 02:42 AM, Levin, Alexander (Sasha Levin) wrote:
>> On Wed, Jun 14, 2017 at 11:37:14AM -0700, Dave Watson wrote:
>> >Add the infrustructure for attaching Upper Layer Protocols (ULPs) over =
TCP
>> >sockets. Based on a similar infrastructure in tcp_cong.  The idea is th=
at any
>> >ULP can add its own logic by changing the TCP proto_ops structure to it=
s own
>> >methods.
>> >
>> >Example usage:
>> >
>> >setsockopt(sock, SOL_TCP, TCP_ULP, "tls", sizeof("tls"));
>> >
>> >modules will call:
>> >tcp_register_ulp(&tcp_tls_ulp_ops);
>> >
>> >to register/unregister their ulp, with an init function and name.
>> >
>> >A list of registered ulps will be returned by tcp_get_available_ulp, wh=
ich is
>> >hooked up to /proc.  Example:
>> >
>> >$ cat /proc/sys/net/ipv4/tcp_available_ulp
>> >tls
>> >
>> >There is currently no functionality to remove or chain ULPs, but
>> >it should be possible to add these in the future if needed.
>> >
>> >Signed-off-by: Boris Pismenny <borisp@mellanox.com>
>> >Signed-off-by: Dave Watson <davejwatson@fb.com>
>>
>> Hey Dave,
>>
>> I'm seeing the following while fuzzing, which was bisected to this commi=
t:
>>
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> BUG: KASAN: null-ptr-deref in copy_to_user include/linux/uaccess.h:168 [=
inline]
>> BUG: KASAN: null-ptr-deref in do_tcp_getsockopt.isra.33+0x24f/0x1e30 net=
/ipv4/tcp.c:3057
>> Read of size 4 at addr 0000000000000020 by task syz-executor1/15452
>
>At a glance, this looks like it was fixed already by
>
>https://www.mail-archive.com/netdev@vger.kernel.org/msg175226.html
>
>Can you recheck with that patch, or verify that you already have it?
>Thanks.

I've already tried this patch, it doesn't fix the issue I've reported.

--=20

Thanks,
Sasha=
