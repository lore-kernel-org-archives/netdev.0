From: Premkumar Jonnala <pjonnala@broadcom.com>
Subject: RE: [PATCH net-next 6/7] bridge: don't age externally added FDB
 entries
Date: Tue, 22 Sep 2015 08:22:17 +0000
Message-ID: <77EF4405DD4BB54AACCE7DB593DF6A9A9F11F7@SJEXCHMB14.corp.ad.broadcom.com>
References: <1442606151-50429-1-git-send-email-sfeldma@gmail.com>
 <1442606151-50429-7-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "jiri@resnulli.us" <jiri@resnulli.us>,
	"siva.mannem.lnx@gmail.com" <siva.mannem.lnx@gmail.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"vivien.didelot@savoirfairelinux.com"
	<vivien.didelot@savoirfairelinux.com>
To: "sfeldma@gmail.com" <sfeldma@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:53416 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932140AbbIVIWU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 04:22:20 -0400
In-Reply-To: <1442606151-50429-7-git-send-email-sfeldma@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Siva Mannem <siva.mannem.lnx@gmail.com>
> 
> Signed-off-by: Siva Mannem <siva.mannem.lnx@gmail.com>
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Acked-by: Premkumar Jonnala <pjonnala@broadcom.com>

> ---
>  net/bridge/br_fdb.c |    2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
> index 9e9875d..6663cc0 100644
> --- a/net/bridge/br_fdb.c
> +++ b/net/bridge/br_fdb.c
> @@ -299,6 +299,8 @@ void br_fdb_cleanup(unsigned long _data)
>  			unsigned long this_timer;
>  			if (f->is_static)
>  				continue;
> +			if (f->added_by_external_learn)
> +				continue;
>  			this_timer = f->updated + delay;
>  			if (time_before_eq(this_timer, jiffies))
>  				fdb_delete(br, f);
> --
> 1.7.10.4
