From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq@rere.qmqm.pl>
Subject: Re: [PATCH 08/11] netlink: implement memory mapped sendmsg()
Date: Sun, 4 Sep 2011 18:18:22 +0200
Message-ID: <20110904161822.GA8176@rere.qmqm.pl>
References: <1315070771-18576-1-git-send-email-kaber@trash.net>
 <1315070771-18576-9-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1315070771-18576-9-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 03, 2011 at 07:26:08PM +0200, kaber@trash.net wrote:
> From: Patrick McHardy <kaber@trash.net>
>=20
> Add support for memory mapped sendmsg() to netlink. Userspace queued =
to
> be processed frames into the TX ring and invokes sendmsg with
> msg.iov.iov_base =3D NULL to trigger processing of all pending messag=
es.
>=20
> Since the kernel usually performs full message validation before begi=
nning
> processing, userspace must be prevented from modifying the message
> contents while the kernel is processing them. In order to do so, the
> frames contents are copied to an allocated skb in case the the ring i=
s
> mapped more than once or the file descriptor is shared (f.i. through
> AF_UNIX file descriptor passing).
>=20
> Otherwise an skb without a data area is allocated, the data pointer s=
et
> to point to the data area of the ring frame and the skb is processed.
> Once the skb is freed, the destructor releases the frame back to user=
space
> by setting the status to NL_MMAP_STATUS_UNUSED.

Is this protected from threads? Like: one thread waits on sendmsg() and
another (same process) changes the buffer.

Best Regards,
Micha=B3 Miros=B3aw
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
