From: Chris Snook <csnook@redhat.com>
Subject: Re: [PATCH] cxgb3: Fix __must_check warning with dev_dbg.
Date: Wed, 02 Apr 2008 11:49:25 -0400
Message-ID: <47F3AB05.6060805@redhat.com>
References: 47F34ECC.7040905@redhat.com <12071370042107-git-send-email-dpn@isomerica.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Dan Noe <dpn@isomerica.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:49109 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754750AbYDBPwW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Apr 2008 11:52:22 -0400
In-Reply-To: <12071370042107-git-send-email-dpn@isomerica.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Noe wrote:
> Fix the warning:
> drivers/net/cxgb3/cxgb3_main.c: In function =E2=80=98offload_open=E2=80=
=99:
> drivers/net/cxgb3/cxgb3_main.c:936: warning: ignoring return value of
>  =E2=80=98sysfs_create_group=E2=80=99, declared with attribute warn_u=
nused_result
>=20
> Now the return value is checked; if sysfs_create_group() returns fail=
ure,
> a warning is printed using dev_dbg, and the code continues as before.=
  Use
> of dev_dbg ensures printk is not needlessly included unless desired f=
or
> debugging.
>=20
> Signed-off-by: Dan Noe <dpn@isomerica.net>
> ---
>  drivers/net/cxgb3/cxgb3_main.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3=
_main.c
> index fd2e05b..0ddc34a 100644
> --- a/drivers/net/cxgb3/cxgb3_main.c
> +++ b/drivers/net/cxgb3/cxgb3_main.c
> @@ -1014,8 +1014,8 @@ static int offload_open(struct net_device *dev)
>  		     adapter->port[0]->mtu : 0xffff);
>  	init_smt(adapter);
> =20
> -	/* Never mind if the next step fails */
> -	sysfs_create_group(&tdev->lldev->dev.kobj, &offload_attr_group);
> +	if (sysfs_create_group(&tdev->lldev->dev.kobj, &offload_attr_group)=
)
> +		dev_dbg(&dev->dev, ": cannot create sysfs group\n");
> =20
>  	/* Call back all registered clients */
>  	cxgb3_add_clients(tdev);

Close.  dev_dbg() invokes dev_printk(), which provides the ": ", so you=
=20
can take those two characters out of the string literal.

-- Chris
