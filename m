From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [BUG] alignment problem in net/core/flow.c:flow_key_compare
Date: Thu, 18 Mar 2004 16:29:03 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040318162903.59192d13.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


This is in 2.6.4:

Begin forwarded message:

Date: Thu, 18 Mar 2004 11:53:02 +0100
From: mru@kth.se (M=E5ns Rullg=E5rd)
To: linux-kernel@vger.kernel.org
Subject: [BUG] alignment problem in net/core/flow.c:flow_key_compare


There is a problem with alignment in the flow_key_compare function in
net/core/flow.c.  It takes arguments of type struct flowi * and casts
them to flow_compare_t *, which is 64 bits on 64-bit machines.  It
then proceeds to read and compare 64-bit values from these pointers.
The problem is that struct flowi only requires 32-bit alignment, so
these reads cause numerous unaligned exceptions.  On average, I get
nearly 1000 unaligned exceptions per second.

The solutions I see are either to force the alignment of struct flowi
to 64 bits, or to use 32-bit access in flow_key_compare.

--=20
M=E5ns Rullg=E5rd
mru@kth.se
-
To unsubscribe from this list: send the line "unsubscribe linux-kernel" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/
