From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ipv4 routing: splitting of
 ip_route_[in|out]put_slow, 2.6.10-rc3
Date: Wed, 2 Feb 2005 17:17:01 -0800
Message-ID: <20050202171701.18a81a6a.davem@davemloft.net>
References: <41C6B3D4.6060207@einar-lueck.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
To: Einar =?ISO-8859-1?Q?L=FCck?= <lkml@einar-lueck.de>
In-Reply-To: <41C6B3D4.6060207@einar-lueck.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 20 Dec 2004 12:13:24 +0100
Einar L=FCck <lkml@einar-lueck.de> wrote:

> This patch splits up ip_route_[in|out]put_slow in inlined functions.
> Basic idea:
> * improve overall comprehensibility
> * allow for an easier application of patch for improved multipath=20
>   support

Patch applied to my 2.6.12 pending tree.  Thanks a lot Einar.

One minor comment is that there are some minor cases where
excessing in_dev get/put can be eliminated.  For example,
in __mkroute_output() we really only need to do the
in_dev_get(dev_out) once, yet we do it twice due to how
the return path of this function always puts the reference
even in the non-error case.
