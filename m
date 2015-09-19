From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 3/7] rocker: adding port ageing_time for ageing
 out FDB entries
Date: Sat, 19 Sep 2015 08:30:58 +0200
Message-ID: <20150919063058.GA2067@nanopsycho.orion>
References: <1442606151-50429-1-git-send-email-sfeldma@gmail.com>
 <1442606151-50429-4-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, siva.mannem.lnx@gmail.com,
	pjonnala@broadcom.com, stephen@networkplumber.org,
	roopa@cumulusnetworks.com, andrew@lunn.ch, f.fainelli@gmail.com,
	vivien.didelot@savoirfairelinux.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:35614 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750778AbbISGbB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Sep 2015 02:31:01 -0400
Received: by wicge5 with SMTP id ge5so56310982wic.0
        for <netdev@vger.kernel.org>; Fri, 18 Sep 2015 23:31:00 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1442606151-50429-4-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Sep 18, 2015 at 09:55:47PM CEST, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>Follow-up patcheset will allow user to change ageing_time, but for now
>just hard-code it to a fixed value (the same value used as the default
>for the bridge driver).
>
>Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>---
> drivers/net/ethernet/rocker/rocker.c |    2 ++
> 1 file changed, 2 insertions(+)
>
>diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
>index f55ed2c..eba22f5 100644
>--- a/drivers/net/ethernet/rocker/rocker.c
>+++ b/drivers/net/ethernet/rocker/rocker.c
>@@ -221,6 +221,7 @@ struct rocker_port {
> 	__be16 internal_vlan_id;
> 	int stp_state;
> 	u32 brport_flags;
>+	unsigned long ageing_time;
> 	bool ctrls[ROCKER_CTRL_MAX];
> 	unsigned long vlan_bitmap[ROCKER_VLAN_BITMAP_LEN];
> 	struct napi_struct napi_tx;
>@@ -4975,6 +4976,7 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
> 	rocker_port->port_number = port_number;
> 	rocker_port->pport = port_number + 1;
> 	rocker_port->brport_flags = BR_LEARNING | BR_LEARNING_SYNC;
>+	rocker_port->ageing_time = 300 * HZ;

How about to add also "BR_DEFAULT_AGEING_TIME" and use it here?
>
