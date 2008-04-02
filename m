From: Chris Snook <csnook@redhat.com>
Subject: Re: [PATCH] cxgb3: Fix __must_check warning.
Date: Wed, 02 Apr 2008 05:15:56 -0400
Message-ID: <47F34ECC.7040905@redhat.com>
References: <1207107342276-git-send-email-dpn@isomerica.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Dan Noe <dpn@isomerica.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:46368 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751721AbYDBJQB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Apr 2008 05:16:01 -0400
In-Reply-To: <1207107342276-git-send-email-dpn@isomerica.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Noe wrote:
> Fix the warning:
> drivers/net/cxgb3/cxgb3_main.c: In function =E2=80=98offload_open=E2=80=
=99:
> drivers/net/cxgb3/cxgb3_main.c:936: warning: ignoring return value of=
 =E2=80=98sysfs_create_group=E2=80=99, declared with attribute warn_unu=
sed_result
>=20
> Now the return value is checked; if sysfs_create_group() returns fail=
ure,
> a warning is printed, and the code continues as before.
>=20
> Signed-off-by: Dan Noe <dpn@isomerica.net>
> ---
>  drivers/net/cxgb3/cxgb3_main.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
>=20
> My first patch - feedback is appreciated, please be gentle.  Thanks!
>=20
> diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3=
_main.c
> index fd2e05b..3007fe1 100644
> --- a/drivers/net/cxgb3/cxgb3_main.c
> +++ b/drivers/net/cxgb3/cxgb3_main.c
> @@ -1015,7 +1015,8 @@ static int offload_open(struct net_device *dev)
>  	init_smt(adapter);
> =20
>  	/* Never mind if the next step fails */
> -	sysfs_create_group(&tdev->lldev->dev.kobj, &offload_attr_group);
> +	if (sysfs_create_group(&tdev->lldev->dev.kobj, &offload_attr_group)=
)
> +		printk(KERN_WARNING DRV_NAME ": cannot create sysfs group\n");

Two things:

1) You've obsoleted the preceding comment, so you might as well remove =
it.

2) The original author quite explicitly didn't think this was worth a=20
printk.  printk calls expand the kernel binary, which has a cost, so we=
=20
shouldn't be adding printk calls *just* to shut up a build warning.=20
Personally, I think this is the sort of thing I might like to know abou=
t=20
if I were debugging something, so it might make sense to make it a=20
dev_dbg.  When DEBUG is not set, no printk gets compiled in, so the=20
binary stays lean, but you can still get the message if you compile wit=
h=20
DEBUG enabled.

-- Chris
