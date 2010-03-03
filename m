From: "Frank W. Miller" <frankwmiller@frankwmiller.net>
Subject: Re: Current wireless-testing breaks libpcap: mr_alen should be set
Date: Wed, 3 Mar 2010 08:31:07 -0700
Message-ID: <A5B3F074CA554D3E95CFD349116E4D5B@FrankWMillerPC>
References: <1267578048.14049.11.camel@mj>
Reply-To: tcpdump-workers@lists.tcpdump.org
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'Jiri Pirko'" <jpirko@redhat.com>
To: <tcpdump-workers@lists.tcpdump.org>,
	<linux-wireless@vger.kernel.org>,
	<netdev@vger.kernel.org>
Return-path: <tcpdump-workers-owner+M5230@lists.tcpdump.org>
In-Reply-To: <1267578048.14049.11.camel@mj>
Sender: tcpdump-workers-owner@lists.tcpdump.org
List-Id: netdev.vger.kernel.org


Would this be preventing pcap_inject() from working say in kernel 2.6.31
(stock FC12 kernel)?

Thanks,
FM


> -----Original Message-----
> From: tcpdump-workers-owner@lists.tcpdump.org [mailto:tcpdump-workers-
> owner@lists.tcpdump.org] On Behalf Of Pavel Roskin
> Sent: Tuesday, March 02, 2010 6:01 PM
> To: linux-wireless@vger.kernel.org; netdev@vger.kernel.org; tcpdump-
> workers@lists.tcpdump.org
> Cc: Jiri Pirko
> Subject: [tcpdump-workers] Current wireless-testing breaks libpcap:
> mr_alen should be set
> 
> Hello!
> 
> The current wireless-testing appears to have some non-wireless bits from
> the upcoming Linux 2.6.34.  As a result, libpcap and all capture
> programs that use it are broken.
> 
> This patch to libpcap helps:
> 
> --- a/pcap-linux.c
> +++ b/pcap-linux.c
> @@ -1563,6 +1563,7 @@ live_open_new(pcap_t *handle, const char
>  			memset(&mr, 0, sizeof(mr));
>  			mr.mr_ifindex = handle->md.ifindex;
>  			mr.mr_type    = PACKET_MR_PROMISC;
> +			mr.mr_alen    = 6;
>  			if (setsockopt(sock_fd, SOL_PACKET,
>  				PACKET_ADD_MEMBERSHIP, &mr, sizeof(mr)) ==
-1)
>  			{
> 
> libpcap git doesn't have the fix yet.
> 
> The breakage must be coming from the commit 914c8ad2 by Jiri Pirko to
> net/packet/af_packet.c
> 
> I think it's very unhelpful to introduce patches that break significant
> userspace functionality without giving the affected programs an advance
> warning.
> 
> Also, pulling bleeding edge stuff into wireless-testing before rc1
> appears to be either a mistake or a bad decision.
> 
> Sorry for cross-post, but it's an urgent issue.  Repliers are encouraged
> to trim the recipient list as necessary.
> 
> --
> Regards,
> Pavel Roskin
> -
> This is the tcpdump-workers list.
> Visit https://cod.sandelman.ca/ to unsubscribe.
