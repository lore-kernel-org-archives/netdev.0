From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: igmp: Reduce Unsolicited report interval to 1s when
 using IGMPv3
Date: Wed, 24 Jul 2013 18:51:25 +0400
Message-ID: <51EFE9ED.4000400@cogentembedded.com>
References: <1374527349.1635.55.camel@bwh-desktop.uk.level5networks.com> <1374673098-10295-1-git-send-email-william.manley@youview.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: William Manley <william.manley@youview.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:47124 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751005Ab3GXOvc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jul 2013 10:51:32 -0400
Received: by mail-la0-f51.google.com with SMTP id fp13so323620lab.24
        for <netdev@vger.kernel.org>; Wed, 24 Jul 2013 07:51:30 -0700 (PDT)
In-Reply-To: <1374673098-10295-1-git-send-email-william.manley@youview.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 24-07-2013 17:38, William Manley wrote:

> If an IGMP join packet is lost you will not receive data sent to the
> multicast group so if no data arrives from that multicast group in a
> period of time after the IGMP join a second IGMP join will be sent.  The
> delay between joins is the "IGMP Unsolicited Report Interval".

> Previously this value was hard coded to be chosen randomly between 0-10s.
> This can be too long for some use-cases, such as IPTV as it can cause
> channel change to be slow in the presence of packet loss.

> The value 10s has come from IGMPv2 RFC2236, which was reduced to 1s in
> IGMPv3 RFC3376.  This patch makes the kernel use the 1s value from the
> later RFC if we are operating in IGMPv3 mode.  IGMPv2 behaviour is
> unaffected.

> Tested with Wireshark and a simple program to join a (non-existant)
> multicast group.  The distribution of timings for the second join differ
> based upon setting /proc/sys/net/ipv4/conf/eth0/force_igmp_version.
> ---
>   net/ipv4/igmp.c |   17 ++++++++++++++---
>   1 file changed, 14 insertions(+), 3 deletions(-)

> diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
> index d8c2327..f8142df 100644
> --- a/net/ipv4/igmp.c
> +++ b/net/ipv4/igmp.c
[...]
> @@ -138,6 +139,15 @@
>   	 ((in_dev)->mr_v2_seen && \
>   	  time_before(jiffies, (in_dev)->mr_v2_seen)))
>
> +static int unsolicited_report_interval(struct in_device *in_dev)
> +{
> +	if (IGMP_V2_SEEN(in_dev)) {
> +		return IGMP_V2_Unsolicited_Report_Interval;
> +	} else { /* v3 */
> +		return IGMP_V3_Unsolicited_Report_Interval;
> +	}

    {} not needed on either arm of *if*. I guess scripts/checkpatch.pl should 
have warned you...

WBR, Sergei
