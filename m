From: Dan Williams <dcbw@redhat.com>
Subject: Re: [patch 5] softmac: report when scanning has finished
Date: Thu, 13 Apr 2006 08:15:01 -0400
Message-ID: <1144930501.2372.14.camel@localhost.localdomain>
References: <20060411085805.949313000@sipsolutions.net>
	 <1144921288.4187.54.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	softmac-dev@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:3213 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S964894AbWDMMQc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2006 08:16:32 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1144921288.4187.54.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-04-13 at 11:41 +0200, Johannes Berg wrote:
> Make softmac report a scan event when scanning has finished, that way
> userspace can wait for the event to happen instead of polling for the
> results.
> 
> Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

ACK, good catch.

Signed-off-by: Dan Williams <dcbw@redhat.com>

> ---
> This patch depends on the previous patch 4. If you want, I can resend
> the whole series with proper patch x/5 headers etc. I don't know if
> these can still go in before .17, but it'd be very good if they could,
> they're essentially bug fixes for things I either didn't know or just
> plain bugs :)
> 
> Index: wireless-2.6/net/ieee80211/softmac/ieee80211softmac_event.c
> ===================================================================
> --- wireless-2.6.orig/net/ieee80211/softmac/ieee80211softmac_event.c	2006-04-13 02:42:59.000000000 +0200
> +++ wireless-2.6/net/ieee80211/softmac/ieee80211softmac_event.c	2006-04-13 11:30:59.896998787 +0200
> @@ -152,6 +152,12 @@
>  			wrqu.ap_addr.sa_family = ARPHRD_ETHER;
>  			we_event = SIOCGIWAP;
>  			break;
> +		case IEEE80211SOFTMAC_EVENT_SCAN_FINISHED:
> +			wrqu.data.length = 0;
> +			wrqu.data.flags = 0;
> +			memset(&wrqu, '\0', sizeof (union iwreq_data));
> +			we_event = SIOCGIWSCAN;
> +			break;
>  		default:
>  			msg = event_descriptions[event];
>  			wrqu.data.length = strlen(msg);
> 

