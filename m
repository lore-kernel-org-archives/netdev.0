From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH V5 1/2] rtnl: Add support for netdev event to link
 messages
Date: Fri, 26 May 2017 13:40:54 -0600
Message-ID: <0d252e48-cbd0-5d5d-1e30-9c7e79ea9d01@gmail.com>
References: <1495726316-27626-1-git-send-email-vyasevic@redhat.com>
 <1495726316-27626-2-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, jiri@resnulli.us, vfalico@gmail.com,
        andy@greyhouse.net, Vladislav Yasevich <vyasevic@redhat.com>
To: Vladislav Yasevich <vyasevich@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34356 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933311AbdEZTlD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 15:41:03 -0400
Received: by mail-pf0-f193.google.com with SMTP id w69so4927933pfk.1
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 12:41:03 -0700 (PDT)
In-Reply-To: <1495726316-27626-2-git-send-email-vyasevic@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/25/17 9:31 AM, Vladislav Yasevich wrote:
> @@ -911,4 +912,14 @@ enum {
>  
>  #define IFLA_XDP_MAX (__IFLA_XDP_MAX - 1)
>  
> +enum {
> +	IFLA_EVENT_UNSPEC,
> +	IFLA_EVENT_REBOOT,
> +	IFLA_EVENT_FEAT_CHANGE,
> +	IFLA_EVENT_BONDING_FAILOVER,
> +	IFLA_EVENT_NOTIFY_PEERS,
> +	IFLA_EVENT_RESEND_IGMP,
> +	IFLA_EVENT_CHANGE_INFO_DATA,
> +};
> +
>  #endif /* _UAPI_LINUX_IF_LINK_H */

I agree these are unique events that userspace might care about.

I'd prefer better names for the userspace api for a couple of those
along with a description in the header file so userspace knows why the
event was generated.

How about something like this:

enum {
	IFLA_EVENT_NONE,
	IFLA_EVENT_REBOOT,		/* internal reset / reboot */
	IFLA_EVENT_FEATURES,		/* change in offload features */
	IFLA_EVENT_BONDING_FAILOVER,	/* change in active slave */
	IFLA_EVENT_NOTIFY_PEERS,	/* re-sent grat. arp/ndisc */
	IFLA_EVENT_IGMP_RESEND,		/* re-sent IGMP JOIN */
	IFLA_EVENT_BONDING_OPTIONS,	/* change in bonding options */
};

Also, generically the IFLA_EVENT attribute should be considered
independent of NETDEV_ events.

For example, userspace should be notified if the speed / duplex for a
device changes, so we could have another one of these -- e.g.,
IFLA_EVENT_SPEED -- that does not correlate to NETDEV_SPEED since
nothing internal to the network stack cares about speed changes, or
perhaps more generically it is IFLA_EVENT_LINK_SETTING.

The rest of the patch looks ok to me.
