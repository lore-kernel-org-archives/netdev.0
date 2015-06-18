From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 19/22] fjes: update_zone_task
Date: Wed, 17 Jun 2015 19:25:07 -0700
Message-ID: <1434594307.2689.102.camel@perches.com>
References: <1434588359-25589-1-git-send-email-izumi.taku@jp.fujitsu.com>
	 <1434588587-25655-1-git-send-email-izumi.taku@jp.fujitsu.com>
	 <1434588587-25655-19-git-send-email-izumi.taku@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: platform-driver-x86@vger.kernel.org, dvhart@infradead.org,
	rkhan@redhat.com, alexander.h.duyck@redhat.com,
	netdev@vger.kernel.org, linux-acpi@vger.kernel.org
To: Taku Izumi <izumi.taku@jp.fujitsu.com>
Return-path: <platform-driver-x86-owner@vger.kernel.org>
In-Reply-To: <1434588587-25655-19-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: platform-driver-x86-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-06-18 at 09:49 +0900, Taku Izumi wrote:
> This patch adds update_zone_task.

> diff --git a/drivers/platform/x86/fjes/fjes_hw.c b/drivers/platform/x86/fjes/fjes_hw.c
[]
> +static void fjes_hw_update_zone_task(struct work_struct *work)
> +{

Some of the line length can be removed here by using a
temporary, but these would look a lot better if you went
beyond 80 columns.

	info = &res_buf->info.info;
[]
> +				case EP_PARTNER_UNSHARE:
> +				default:
> +					if ((res_buf->info.info[epidx].zone !=
> +						FJES_ZONING_ZONE_TYPE_NONE) &&
> +					    (res_buf->info.info[epidx].es_status ==
> +						FJES_ZONING_STATUS_ENABLE) &&
> +					    (res_buf->info.info[epidx].zone ==
> +						res_buf->info.info[hw->my_epid].zone))

So these become
					if ((info[epidx].zone != FJES_ZONING_ZONE_TYPE_NONE) &&
					    (info[epidx].es_status == FJES_ZONING_STATUS_ENABLE) &&
					    (info[epidx].zone == info[hw->my_epid.zone))

> +				case EP_PARTNER_COMPLETE:
> +				case EP_PARTNER_WAITING:
> +					if ((res_buf->info.info[epidx].zone ==
> +						FJES_ZONING_ZONE_TYPE_NONE) ||
> +					    (res_buf->info.info[epidx].es_status !=
> +						FJES_ZONING_STATUS_ENABLE) ||
> +					    (res_buf->info.info[epidx].zone !=
> +						res_buf->info.
> +						  info[hw->my_epid].zone)) {

etc...
