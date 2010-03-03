From: Jiri Pirko <jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: Current wireless-testing breaks libpcap: mr_alen should be set
Date: Wed, 3 Mar 2010 07:24:00 +0100
Message-ID: <20100303062359.GA2648@psychotron.redhat.com>
References: <1267578048.14049.11.camel@mj>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	tcpdump-workers-YE1jQ5a0g24KACXWX4p+q9i2O/JbrIOy@public.gmane.org
To: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1267578048.14049.11.camel@mj>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Wed, Mar 03, 2010 at 02:00:48AM CET, proski-mXXj517/zsQ@public.gmane.org wrote:
>Hello!
>
>The current wireless-testing appears to have some non-wireless bits from
>the upcoming Linux 2.6.34.  As a result, libpcap and all capture
>programs that use it are broken.
>
>This patch to libpcap helps:
>
>--- a/pcap-linux.c
>+++ b/pcap-linux.c
>@@ -1563,6 +1563,7 @@ live_open_new(pcap_t *handle, const char
> 			memset(&mr, 0, sizeof(mr));
> 			mr.mr_ifindex = handle->md.ifindex;
> 			mr.mr_type    = PACKET_MR_PROMISC;
>+			mr.mr_alen    = 6;
> 			if (setsockopt(sock_fd, SOL_PACKET,
> 				PACKET_ADD_MEMBERSHIP, &mr, sizeof(mr)) == -1)
> 			{
>
>libpcap git doesn't have the fix yet.
>
>The breakage must be coming from the commit 914c8ad2 by Jiri Pirko to
>net/packet/af_packet.c
>
>I think it's very unhelpful to introduce patches that break significant
>userspace functionality without giving the affected programs an advance
>warning.
>
>Also, pulling bleeding edge stuff into wireless-testing before rc1
>appears to be either a mistake or a bad decision.
>
>Sorry for cross-post, but it's an urgent issue.  Repliers are encouraged
>to trim the recipient list as necessary.

Sorry about this. Corrected patch will follow.

Jirka
>
>-- 
>Regards,
>Pavel Roskin
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
