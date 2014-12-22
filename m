From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [RFC PATCH net-next] tun: support retrieving multiple packets in
 a single read with IFF_MULTI_READ
Date: Mon, 22 Dec 2014 12:51:57 -0800
Message-ID: <CAA93jw7+tV2bX+PeOs5Emh47n7AqigbxGuhPZxC+1kWO5v2k_Q@mail.gmail.com>
References: <20141222120957.GA21319@gondor.apana.org.au>
	<54987C9F.5070103@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>, jasonwang@redhat.com,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Michael S. Tsirkin" <mst@redhat.com>, herbert@gondor.apena.org.au,
	kernel-team@fb.com
To: Alex Gartrell <agartrell@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54987C9F.5070103@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 22, 2014 at 12:18 PM, Alex Gartrell <agartrell@fb.com> wrot=
e:
> Hey Herbert,
>
> Thanks for getting back to me
>
> On 12/22/14 4:09 AM, Herbert Xu wrote:
>>
>> As tun already has a socket interface can we do this through
>> recvmmsg?
>
>
> This just presents an easier interface (IMHO) for accomplishing that.=
 And I
> say easier because I was unable how to figure out the recvmmsg way to=
 do it.

the recvmsg and recvmmsg calls and layers above them could use an abstr=
action
that allows for better passing of per packet header information to appl=
ications
in the QUIC and webrtc age.

> While fully aware that this makes me look like an idiot, I have to ad=
mit

I have lost several days of hair to *msg calls. So have the authors of
multipath mosh
(which is WAY cool, btw: https://github.com/boutier/mosh

So, no, trying and failing does not make you an idiot. Trying at all do=
es
make you a mite crazy, however. :)

> that I've tried and failed to figure out how to get a socket fd out o=
f the
> tun device.
>
> The regular fd doesn't work (which is obvious when you look at the
> implementation sock_from_file), there's a tun_get_socket function but=
 it's
> only referenced by a single file, and none of the ioctl's jump out at=
 me as
> doing anything to enable this behavior.  Additionally, tuntap.txt mak=
es no
> mention of sockets specifically.
>
> FWIW, I don't feel strongly that IFF_MULTI_READ is the right way to d=
o this
> either.

I have been thinking about how to implement multiple ways of eliminatin=
g
serialization dependencies in userspace vpns using fair queueing, and
multithreading...
(with splitting out the seqno + address across an entire /64)

=2E.. and excess latency with multipacket reads, and then codeling
internal queues (as many vpns
bottleneck on the encap and encode step allowing for packets to
accumulate in the OS recv buffer)

See:

http://www.tinc-vpn.org/pipermail/tinc-devel/2014-December/000680.html

And especially:

https://plus.google.com/u/0/107942175615993706558/posts/QWPWLoGMtrm

and after having just suffered through making that work with recvmsg,
was dreading trying to make it work with recvmmsg.

It appears that one of the core crazy ideas (listening on an entire
/64) doesn=C2=B4t work with the existing APIs, and this new interface w=
ould
help? Or recvmmsg could be generalized? Or?


--=20
Dave T=C3=A4ht

http://www.bufferbloat.net/projects/bloat/wiki/Upcoming_Talks
