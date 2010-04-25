From: Sedat Dilek <sedat.dilek@googlemail.com>
Subject: Re: [2.6.34-rc5-git6] EIP: is at inet6_csk_bind_conflict + 06xe/0xb7
	[ipv6]
Date: Sun, 25 Apr 2010 18:55:52 +0200
Message-ID: <j2p2d0a357f1004250955i59969a2cp9fd9eb9f3ef22d4b@mail.gmail.com>
References: <l2z2d0a357f1004250811w6da355ebp95d1730473026c22@mail.gmail.com>
	 <4BD45E68.4080900@example.com>
	 <g2z2d0a357f1004250931pf5880c60l32fd0643e0f14bde@mail.gmail.com>
	 <4BD46F9C.5060500@example.com>
	 <1272213597.2069.32.camel@edumazet-laptop>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=0016e6d46d7d818aef0485128874
Cc: piotr@hosowicz.com, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Jiri Olsa <jolsa@redhat.com>,
	Jongman Heo <jongman.heo@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1272213597.2069.32.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--0016e6d46d7d818aef0485128874
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Rebuild ipv6 kernel-modules by:

$ make M=3Dnet/ipv6

...and copied net/ipv6/*.ko and net/ipv6/netfilter/*.ko files manually
to the right place.

Applied your patch (seen on netdev ML) already and booted into new kernel.
Works, thanks.

Tested-by: Sedat Dilek <sedat.dilek@gmail.com>

- Sedat -

On Sun, Apr 25, 2010 at 6:39 PM, Eric Dumazet <eric.dumazet@gmail.com> wrot=
e:
> Le dimanche 25 avril 2010 =C3=A0 18:36 +0200, Piotr Hosowicz a =C3=A9crit=
 :
>> On 25.04.2010 18:31, Sedat Dilek wrote:
>> > [ CCing netdev ML ]
>> >
>> > Confirmed: The revert-patch [1] fixes the problem here.
>>
>> I confirm, I've built a git6 kernel and it works fine.
>>
>> > See also "Bug 15847 - =C2=A0crash in inet6_csk_bind_conflict" [2].
>> >
>> > Feel free to add a... Tested-by: Sedat Dilek<sedat.dilek@gmail.com>
>>
>> I added created and tested phrase in my archive. ;-) Thank you a lot. I
>> hope there will be no this error in git7.
>>
>
> Did you test the proposed fix ?
>
>
> [PATCH] ipv6: Fix inet6_csk_bind_conflict()
>
> Commit fda48a0d7a84 (tcp: bind() fix when many ports are bound)
> introduced a bug on IPV6 part.
> We should not call ipv6_addr_any(inet6_rcv_saddr(sk2)) but
> ipv6_addr_any(inet6_rcv_saddr(sk)) because sk2 can be IPV4, while sk is
> IPV6.
>
> Reported-by: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection=
_sock.c
> index b4b7d40..3a4d92b 100644
> --- a/net/ipv6/inet6_connection_sock.c
> +++ b/net/ipv6/inet6_connection_sock.c
> @@ -48,7 +48,7 @@ int inet6_csk_bind_conflict(const struct sock *sk,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 ipv6_rcv_saddr_equal(sk, sk2))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0break;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0else if (sk->sk_reuse && sk2->sk_reuse &&
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 !ipv6_addr_any(inet6_rcv_saddr(sk2)) &&
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 !ipv6_addr_any(inet6_rcv_saddr(sk)) &&
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ipv6_rcv_saddr_equal(sk, sk2))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0break;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
>
>

--0016e6d46d7d818aef0485128874
Content-Type: text/x-diff; charset=US-ASCII; name="ipv6-Fix-inet6_csk_bind_conflict.patch"
Content-Disposition: attachment;
	filename="ipv6-Fix-inet6_csk_bind_conflict.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_g8g3l7r10

W1BBVENIXSBpcHY2OiBGaXggaW5ldDZfY3NrX2JpbmRfY29uZmxpY3QoKQoKQ29tbWl0IGZkYTQ4
YTBkN2E4NCAodGNwOiBiaW5kKCkgZml4IHdoZW4gbWFueSBwb3J0cyBhcmUgYm91bmQpCmludHJv
ZHVjZWQgYSBidWcgb24gSVBWNiBwYXJ0LgpXZSBzaG91bGQgbm90IGNhbGwgaXB2Nl9hZGRyX2Fu
eShpbmV0Nl9yY3Zfc2FkZHIoc2syKSkgYnV0CmlwdjZfYWRkcl9hbnkoaW5ldDZfcmN2X3NhZGRy
KHNrKSkgYmVjYXVzZSBzazIgY2FuIGJlIElQVjQsIHdoaWxlIHNrIGlzCklQVjYuCgpSZXBvcnRl
ZC1ieTogTWljaGFlbCBTLiBUc2lya2luIDxtc3RAcmVkaGF0LmNvbT4KU2lnbmVkLW9mZi1ieTog
RXJpYyBEdW1hemV0IDxlcmljLmR1bWF6ZXRAZ21haWwuY29tPgotLS0KZGlmZiAtLWdpdCBhL25l
dC9pcHY2L2luZXQ2X2Nvbm5lY3Rpb25fc29jay5jIGIvbmV0L2lwdjYvaW5ldDZfY29ubmVjdGlv
bl9zb2NrLmMKaW5kZXggYjRiN2Q0MC4uM2E0ZDkyYiAxMDA2NDQKLS0tIGEvbmV0L2lwdjYvaW5l
dDZfY29ubmVjdGlvbl9zb2NrLmMKKysrIGIvbmV0L2lwdjYvaW5ldDZfY29ubmVjdGlvbl9zb2Nr
LmMKQEAgLTQ4LDcgKzQ4LDcgQEAgaW50IGluZXQ2X2Nza19iaW5kX2NvbmZsaWN0KGNvbnN0IHN0
cnVjdCBzb2NrICpzaywKIAkJCSAgICAgaXB2Nl9yY3Zfc2FkZHJfZXF1YWwoc2ssIHNrMikpCiAJ
CQkJYnJlYWs7CiAJCQllbHNlIGlmIChzay0+c2tfcmV1c2UgJiYgc2syLT5za19yZXVzZSAmJgot
CQkJCSFpcHY2X2FkZHJfYW55KGluZXQ2X3Jjdl9zYWRkcihzazIpKSAmJgorCQkJCSFpcHY2X2Fk
ZHJfYW55KGluZXQ2X3Jjdl9zYWRkcihzaykpICYmCiAJCQkJaXB2Nl9yY3Zfc2FkZHJfZXF1YWwo
c2ssIHNrMikpCiAJCQkJYnJlYWs7CiAJCX0K
--0016e6d46d7d818aef0485128874--
