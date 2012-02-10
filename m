From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: RE: [PATCH net-next] drivers/net: Remove boolean comparisons to
 true/false
Date: Fri, 10 Feb 2012 14:04:22 +0100
Message-ID: <1328879062.2443.16.camel@edumazet-laptop>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B6E65@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6E65-CgBM+Bx2aUAnGFn1LkZF6NBPR1lH4CV8@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le vendredi 10 f=C3=A9vrier 2012 =C3=A0 09:32 +0000, David Laight a =C3=
=A9crit :

> The generated code is particularly horrid for boolean arithmetic.
> IIRC:
>    bool_var &=3D bool_var_1;
> typically requires a sequence of compare and branch instructions.
>=20

I suggest you try to upgrade your old compiler and/or always check your
assertions before posting on netdev such claims.

	bool_var &=3D bool_var_1;

generates a single AND instruction, no compare, no branch.
It would be a failure from compiler optimizer if that was the case.

And (bool_var ? 1 : 0) or (!!bool_var) are NOP for a compiler as well.

(Only one movzbl instruction to convert a byte to a word if context
requires this)

Only difference for bool or unsigned int vars is type promotion, and
fact that compiler knows that 'bool' only can be 0 or 1, so allows more
optimisations than plain "unsigned int".

Really, bools are not evil if well used.


--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
