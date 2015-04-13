From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v4 07/24] switchdev: add port vlan obj
Date: Mon, 13 Apr 2015 10:49:04 -0700
Message-ID: <552C0190.8080606@gmail.com>
References: <1428905838-14920-1-git-send-email-sfeldma@gmail.com> <1428905838-14920-8-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	sridhar.samudrala@intel.com, ronen.arad@intel.com, andrew@lunn.ch
To: sfeldma@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:36051 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754449AbbDMRuI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 13:50:08 -0400
Received: by pdea3 with SMTP id a3so114578016pde.3
        for <netdev@vger.kernel.org>; Mon, 13 Apr 2015 10:50:08 -0700 (PDT)
In-Reply-To: <1428905838-14920-8-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/04/15 23:17, sfeldma@gmail.com wrote:
> From: Scott Feldman <sfeldma@gmail.com>
> 
> VLAN obj has flags (PVID and untagged) as well as start and end vid ranges.
> The swdev driver can optimize programing the device using the ranges.
> 
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> ---
>  include/net/switchdev.h |    8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> diff --git a/include/net/switchdev.h b/include/net/switchdev.h
> index f5f7733..d3cc8eb 100644
> --- a/include/net/switchdev.h
> +++ b/include/net/switchdev.h
> @@ -45,12 +45,20 @@ struct fib_info;
>  
>  enum swdev_obj_id {
>  	SWDEV_OBJ_UNDEFINED,
> +	SWDEV_OBJ_PORT_VLAN,
>  };
>  
>  struct swdev_obj {
>  	enum swdev_obj_id id;
>  	enum swdev_trans trans;
>  	u32 flags;
> +	union {
> +		struct swdev_obj_vlan {			/* PORT_VLAN */
> +			u16 flags;

Should not we enforce some sort of definition of how we plan on using
the "flags" member here?, if not, we might just as well remove it from
this patch set until we actually use it?
-- 
Florian
