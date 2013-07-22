From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 1/2] ss: Fix compiler errors of unused
 return-values
Date: Mon, 22 Jul 2013 07:54:10 -0700
Message-ID: <20130722075410.78532ad4@nehalam.linuxnetplumber.net>
References: <1374350298-1177-1-git-send-email-christoph.paasch@uclouvain.be>
	<1374350298-1177-2-git-send-email-christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Christoph Paasch <christoph.paasch@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:34624 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755655Ab3GVOyN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 10:54:13 -0400
Received: by mail-pb0-f50.google.com with SMTP id wz7so7190901pbc.9
        for <netdev@vger.kernel.org>; Mon, 22 Jul 2013 07:54:12 -0700 (PDT)
In-Reply-To: <1374350298-1177-2-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 20 Jul 2013 21:58:17 +0200
Christoph Paasch <christoph.paasch@uclouvain.be> wrote:

> Many errors when compiling with gcc 4.7.3 about unused return-values
> upon the calls to fgets and fscanf:
>=20
> ss.c: In function =E2=80=98user_ent_hash_build=E2=80=99:
> ss.c:305:12: error: ignoring return value of =E2=80=98fscanf=E2=80=99=
, declared with attribute warn_unused_result [-Werror=3Dunused-result]
> ss.c: In function =E2=80=98get_slabstat=E2=80=99:
> ss.c:387:7: error: ignoring return value of =E2=80=98fgets=E2=80=99, =
declared with attribute warn_unused_result [-Werror=3Dunused-result]
> ss.c: In function =E2=80=98init_service_resolver=E2=80=99:
> ss.c:511:8: error: ignoring return value of =E2=80=98fgets=E2=80=99, =
declared with attribute warn_unused_result [-Werror=3Dunused-result]
> ss.c: In function =E2=80=98run_ssfilter=E2=80=99:
> ss.c:728:11: error: ignoring return value of =E2=80=98fscanf=E2=80=99=
, declared with attribute warn_unused_result [-Werror=3Dunused-result]
> ss.c: In function =E2=80=98is_ephemeral=E2=80=99:
> ss.c:550:10: error: ignoring return value of =E2=80=98fscanf=E2=80=99=
, declared with attribute warn_unused_result [-Werror=3Dunused-result]
> ss.c: In function =E2=80=98netlink_show=E2=80=99:
> ss.c:2836:7: error: ignoring return value of =E2=80=98fgets=E2=80=99,=
 declared with attribute warn_unused_result [-Werror=3Dunused-result]
> ss.c: In function =E2=80=98packet_show=E2=80=99:
> ss.c:2630:7: error: ignoring return value of =E2=80=98fgets=E2=80=99,=
 declared with attribute warn_unused_result [-Werror=3Dunused-result]
> ss.c: In function =E2=80=98unix_show=E2=80=99:
> ss.c:2364:7: error: ignoring return value of =E2=80=98fgets=E2=80=99,=
 declared with attribute warn_unused_result [-Werror=3Dunused-result]
> cc1: all warnings being treated as errors
> make[1]: *** [ss.o] Error 1
> make[1]: Leaving directory `/home/christoph/workspace/linux/iproute2/=
misc'
> make: *** [all] Error 2
>=20
> For the calls to fscanf we can't really do anything about it, and jus=
t
> do an empty if-statement to make the compiler happy.
>=20
>

I would prefer an error message rather than silently exiting.
