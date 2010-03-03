From: Pavel Roskin <proski@gnu.org>
Subject: Current wireless-testing breaks libpcap: mr_alen should be set
Date: Tue, 02 Mar 2010 20:00:48 -0500
Message-ID: <1267578048.14049.11.camel@mj>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jpirko@redhat.com>
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	tcpdump-workers@lists.tcpdump.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from c60.cesmail.net ([216.154.195.49]:64492 "EHLO c60.cesmail.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754134Ab0CCBBE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Mar 2010 20:01:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

The current wireless-testing appears to have some non-wireless bits from
the upcoming Linux 2.6.34.  As a result, libpcap and all capture
programs that use it are broken.

This patch to libpcap helps:

--- a/pcap-linux.c
+++ b/pcap-linux.c
@@ -1563,6 +1563,7 @@ live_open_new(pcap_t *handle, const char
 			memset(&mr, 0, sizeof(mr));
 			mr.mr_ifindex = handle->md.ifindex;
 			mr.mr_type    = PACKET_MR_PROMISC;
+			mr.mr_alen    = 6;
 			if (setsockopt(sock_fd, SOL_PACKET,
 				PACKET_ADD_MEMBERSHIP, &mr, sizeof(mr)) == -1)
 			{

libpcap git doesn't have the fix yet.

The breakage must be coming from the commit 914c8ad2 by Jiri Pirko to
net/packet/af_packet.c

I think it's very unhelpful to introduce patches that break significant
userspace functionality without giving the affected programs an advance
warning.

Also, pulling bleeding edge stuff into wireless-testing before rc1
appears to be either a mistake or a bad decision.

Sorry for cross-post, but it's an urgent issue.  Repliers are encouraged
to trim the recipient list as necessary.

-- 
Regards,
Pavel Roskin
