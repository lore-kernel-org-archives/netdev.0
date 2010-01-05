From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] net: packet: option to only pass skb protocol
Date: Tue, 5 Jan 2010 22:50:40 +0200
Message-ID: <20100105205040.GA30921@redhat.com>
References: <20100105185732.GA30346@redhat.com> <4B439299.1090205@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755659Ab0AEUxp@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B439299.1090205@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 05, 2010 at 08:27:21PM +0100, Eric Dumazet wrote:
> Le 05/01/2010 19:57, Michael S. Tsirkin a =E9crit :
> > When sending packets with a packet socket it is often necessary to =
set
> > protocol in msg_name: otherwise the protocol field in the skb will =
not
> > be set correctly.  However, currently doing this also requires
> > supplying the interface index.
> >=20
> > The following patch makes it possible to avoid supplying the interf=
ace
> > index by interpreting index 0 as "use device this socket is bound t=
o".
> >=20
>=20
> Patch is correct, but I dont understand why zero initialization by ca=
ller
> is any better then supplying ifindex (known when socket was bound to =
device ?)
>=20
> To avoid one syscall at socket setup (to get ifindex from dev name),
> you prefer to add a test/branch at each send() syscall...
>=20
> Am I missing something ?

binding socket to device might be done by a separate process
from the one doing sendmsg, and IMO the device socket is bound
to might change at any time.

So the sending process would need to get socket name before
each sendmsg.

Makes sense?

--=20
MST
