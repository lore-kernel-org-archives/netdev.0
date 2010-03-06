From: Guy Harris <guy@alum.mit.edu>
Subject: Re: [tcpdump-workers] Current wireless-testing breaks libpcap: mr_alen should be set
Date: Sat, 6 Mar 2010 13:23:12 -0800
Message-ID: <7D621661-59E7-46C4-9E86-1D9654A626E7@alum.mit.edu>
References: <1267578048.14049.11.camel@mj>
Mime-Version: 1.0 (Apple Message framework v1077)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Jiri Pirko <jpirko@redhat.com>
To: tcpdump-workers@lists.tcpdump.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from b.mail.sonic.net ([64.142.19.5]:60465 "EHLO b.mail.sonic.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752412Ab0CFWCT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Mar 2010 17:02:19 -0500
In-Reply-To: <1267578048.14049.11.camel@mj>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mar 2, 2010, at 5:00 PM, Pavel Roskin wrote:

> This patch to libpcap helps:
> 
> --- a/pcap-linux.c
> +++ b/pcap-linux.c
> @@ -1563,6 +1563,7 @@ live_open_new(pcap_t *handle, const char
> 			memset(&mr, 0, sizeof(mr));
> 			mr.mr_ifindex = handle->md.ifindex;
> 			mr.mr_type    = PACKET_MR_PROMISC;
> +			mr.mr_alen    = 6;

If there are any network types that support promiscuous mode and have link-layer addresses that aren't 6 octets long, that would still fail.

It sounds as if the fix is not to care about the address length if the address isn't used, so you don't need to get the length right for PACKET_MR_PROMISC or PACKET_MR_ALLMULTI, so libpcap, and other clients setting promiscuous or "show me all multicast packets" mode, don't need to change.  Is that the case?
