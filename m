From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v2 1/2] rtnetlink: add new RTM_GETSTATS message
 to dump link stats
Date: Sat, 9 Apr 2016 10:30:37 -0400
Message-ID: <5709120D.9010107@mojatatu.com>
References: <1460183892-57286-2-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Roopa Prabhu <roopa@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:37857 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751534AbcDIOap (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Apr 2016 10:30:45 -0400
Received: by mail-ig0-f175.google.com with SMTP id g8so38832032igr.0
        for <netdev@vger.kernel.org>; Sat, 09 Apr 2016 07:30:44 -0700 (PDT)
In-Reply-To: <1460183892-57286-2-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Thanks for doing the work Roopa and I apologize for late comments
below:

On 16-04-09 02:38 AM, Roopa Prabhu wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>

> This patch also allows for af family stats (an example af stats for IPV6
> is available with the second patch in the series).
>
> Like any other rtnetlink message, RTM_GETSTATS can be used to get stats of
> a single interface or all interfaces with NLM_F_DUMP.
>
> Future possible new types of stat attributes:
> - IFLA_MPLS_STATS  (nested. for mpls/mdev stats)
> - IFLA_EXTENDED_STATS (nested. extended software netdev stats like bridge,
>    vlan, vxlan etc)
> - IFLA_EXTENDED_HW_STATS (nested. extended hardware stats which are
>    available via ethtool today)
>

I got the extended_hw_stats (which are very common in a lot of ASICS) if
you mean stats on packet sizes. But would the other extended stats not
just be per netdev kind specific? We have concept of XSTATS which maybe
a fit.

> This patch also declares a filter mask for all stat attributes.
> User has to provide a mask of stats attributes to query. This will be
> specified in a new hdr 'struct if_stats_msg' for stats messages.
>
> Without any attributes in the filter_mask, no stats will be returned.
>

Should such a command then not be rejected with an error code?

> +/* STATS section */
> +
> +struct if_stats_msg {
> +	__u8  family;
> +	__u32 ifindex;
> +	__u32 filter_mask;
> +};

Needs to be 32 bit aligned.
Do you need 32 bits for the filter mask?
Perhaps a 16bit mask and an 8bit pad for future use.

struct if_stats_msg {
            __u32 ifindex;
	   __u16 filter_mask;
	   __u8  family;
            __u8 pad; /* future use */
};

Or you could reverse those (from smallest to largest).
BTW, any plans to do the cool feature where i inject a timeout period
and i just get STATS events ;-> The filter struct would have to be more
sophisticated - user would need to pass a list of ifindices and
filter_mask as well as timeout.

cheers,
jamal
