From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 2.6] ixgb: fix ixgb_intr looping checks
Date: Wed, 10 Nov 2004 11:19:33 -0800
Message-ID: <20041110111933.0021cf37.akpm@osdl.org>
References: <20041108151048.4bf605c1.akpm@osdl.org>
	<Pine.LNX.4.44.0411101712080.16936-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: jesse.brandeburg@intel.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
In-Reply-To: <Pine.LNX.4.44.0411101712080.16936-100000@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jesse Brandeburg <jesse.brandeburg@intel.com> wrote:
>
> On Mon, 8 Nov 2004, Andrew Morton wrote:
>  > > This patch undoes a change that we believe will impact performance
>  > adversely,
>  > > by creating possibly too long a delay between servicing completion=
s.
>  >=20
>  > Maybe.=A0 But now take a look at how much additional pointless work =
will be
>  > done in the common case.=A0 For instance, every tx completion will i=
ncur a
>  > call to ixgb_clean_rx_irq(), which then calls ixgb_alloc_rx_buffers(=
).
>=20
>  Is your common case transmits only?

hm, good question.  Usually not, I guess.  IIRC TCP normally runs with
2Tx:1Rx.  NFS-over-UDP will send and receive a lot of back-to-back frames.
