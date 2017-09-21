From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 1/1] ip: ip_print: if no json obj is initialized default
 fp is stdout
Date: Wed, 20 Sep 2017 18:04:34 -0700
Message-ID: <20170920180434.63e38d02@xeon-e3>
References: <20170920221914.92740-1-julien@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, dsa@cumulusnetworks.com
To: Julien Fortin <julien@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:52708 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751842AbdIUBEh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 21:04:37 -0400
Received: by mail-pg0-f44.google.com with SMTP id i195so2634211pgd.9
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 18:04:37 -0700 (PDT)
In-Reply-To: <20170920221914.92740-1-julien@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 20 Sep 2017 15:19:14 -0700
Julien Fortin <julien@cumulusnetworks.com> wrote:

> From: Julien Fortin <julien@cumulusnetworks.com>
>=20
> The ip monitor didn't call `new_json_obj` (even for in non json context),
> so the static FILE* _fp variable wasn't initialized, thus raising a
> SIGSEGV in ipaddress.c. This patch should fix this issue for good, new
> paths won't have to call `new_json_obj`.
>=20
> $ ip -t mon label link
>     fmt=3Dfmt@entry=3D0x45460d =E2=80=9C%d: =E2=80=9C, value=3D<optimized=
 out>) at ip_print.c:132
>     #3  0x000000000040ccd2 in print_int (value=3D<optimized out>, fmt=3D0=
x45460d =E2=80=9C%d: =E2=80=9C, key=3D0x4545fc =E2=80=9Cifindex=E2=80=9D, t=
=3DPRINT_ANY) at ip_common.h:189
>     #4  print_linkinfo (who=3D<optimized out>, n=3D0x7fffffffa380, arg=3D=
0x7ffff77a82a0 <_IO_2_1_stdout_>) at ipaddress.c:1107
>     #5  0x0000000000422e13 in accept_msg (who=3D0x7fffffff8320, ctrl=3D0x=
7fffffff8310, n=3D0x7fffffffa380, arg=3D0x7ffff77a82a0 <_IO_2_1_stdout_>) a=
t ipmonitor.c:89
>     #6  0x000000000044c58f in rtnl_listen (rtnl=3D0x672160 <rth>, handler=
=3Dhandler@entry=3D0x422c70 <accept_msg>, jarg=3D0x7ffff77a82a0 <_IO_2_1_st=
dout_>)
>         at libnetlink.c:761
> 	#7  0x00000000004233db in do_ipmonitor (argc=3D<optimized out>, argv=3D0=
x7fffffffe5a0) at ipmonitor.c:310
> 	#8  0x0000000000408f74 in do_cmd (argv0=3D0x7fffffffe7f5 =E2=80=9Cmon=E2=
=80=9D, argc=3D3, argv=3D0x7fffffffe588) at ip.c:116
> 	#9  0x0000000000408a94 in main (argc=3D4, argv=3D0x7fffffffe580) at ip.c=
:311
>=20
> Traceback can be seen when running the following command in a new termina=
l.
> $ ip link add dev br0 type bridge
>=20
> Fixes: 6377572f ("ip: ip_print: add new API to print JSON or regular form=
at output")
> Reported-by: David Ahern <dsa@cumulusnetworks.com>
> Reviewed-by: David Ahern <dsa@cumulusnetworks.com>
> Signed-off-by: Julien Fortin <julien@cumulusnetworks.com>
> ---

The fix looks correct, but the patch has minor style format issue.

ERROR: "foo* bar" should be "foo *bar"
#54: FILE: ip/ip_print.c:26:
+static inline FILE* _get_fp(void)
