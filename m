From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [Bugme-new] [Bug 14685] New: 2.6.30 -> 2.6.31: very high
 number of RX dropped in bnx2
Date: Mon, 30 Nov 2009 09:44:53 -0800
Message-ID: <1259603093.14964.79.camel@nseg_linux_HP1.broadcom.com>
References: <C27F8246C663564A84BB7AB34397724218065B9853@IRVEXCHCCR01.corp.ad.broadcom.com>
 <alpine.LNX.1.10.0911301632550.21971@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "'Andrew Morton'" <akpm@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bugzilla-daemon@bugzilla.kernel.org"
	<bugzilla-daemon@bugzilla.kernel.org>,
	"bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>
To: "Krzysztof Oledzki" <ole@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1127 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753284AbZK3R4i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Nov 2009 12:56:38 -0500
In-Reply-To: <alpine.LNX.1.10.0911301632550.21971@bizon.gios.gov.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 2009-11-30 at 07:33 -0800, Krzysztof Oledzki wrote:
> # ethtool -S eth0|egrep "(rx_bcast_packets|rx_mcast_packets|
> rx_fw_discards)"
>       rx_mcast_packets: 2806
>       rx_bcast_packets: 790016
>       rx_fw_discards: 790016

This tells me that all the dropped packets are occurring in the iSCSI
ring.

We have recently enabled iSCSI in the kernel and you probably don't have
the userspace components to handle the iSCSI ring.  All broadcast
packets are also received in the iSCSI ring and they are all dropped in
this case without the userspace components.  Networking is not affected.
If you rmmod the bnx2i and cnic drivers, the drop counter should stop
counting.

We have newer firmware that will not include dropped iSCSI packets in
the networking counters.  It should appear in the 2.6.33 kernel
time-frame.

Thanks.


