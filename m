From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Fix checksum bug for multicast/broadcast packets on
 postrouting hook
Date: Sat, 14 Feb 2004 15:00:41 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040214150041.5f6e7ef2.davem@redhat.com>
References: <Xine.LNX.4.44.0402141318490.6128-100000@thoron.boston.redhat.com>
	<402E71E2.1040508@kolumbus.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: jmorris@redhat.com, laforge@netfilter.org, netdev@oss.sgi.com,
        sds@epoch.ncsc.mil
Return-path: <netdev-bounce@oss.sgi.com>
To: Mika =?ISO-8859-1?Q?Penttil=E4?= <mika.penttila@kolumbus.fi>
In-Reply-To: <402E71E2.1040508@kolumbus.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 14 Feb 2004 21:07:14 +0200
Mika Penttil=E4 <mika.penttila@kolumbus.fi> wrote:

> This is unneeded overhead for the common case. The right fix is to make=
=20
> sure the modifier (netfilter etc) makes the copy if needed. Actually,=20
> this is what skb_ip_make_writable() is doing.

I totally agree.

In postrouting hook, the handler must unshare the SKB if it wishes to
modify the packet contents.  It sounds to me like the selinux hooks are
not doing this, and as suggested they should look at using the routine
skb_ip_make_writable() which was designed by Rusty for this.
