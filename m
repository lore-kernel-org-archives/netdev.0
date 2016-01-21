From: Ian Campbell <ian.campbell@citrix.com>
Subject: stable backport of 3 xen multiqueue network dev fixes
Date: Thu, 21 Jan 2016 11:58:10 +0000
Message-ID: <1453377490.4320.16.camel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xen-devel <xen-devel@lists.xen.org>, Wei Liu <wei.liu2@citrix.com>,
	"Boris Ostrovsky" <boris.ostrovsky@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>
To: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:31100 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751189AbcAUMAF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jan 2016 07:00:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Please could you queue these three:

32a8440 xen-netfront: respect user provided max_queues
4c82ac3 xen-netback: respect user provided max_queues
ca88ea1 xen-netfront: update num_queues to real created

for stable backports to at least 4.1. Multiqueue was added in v3.16 so I
think they could all go to LTS that far back.

Users are tripping over issues in the field with exhausting the number of
Xen grant entries available to guests when creating large numbers of queues
(which happens with guests with >=32 VCPUs).

ca88ea1 is a fix which causes the failure to allocate grants for all of the
desired queues gracefully, rather than crashing or failing to pass any
traffic.

32a8440 and 4c82ac3 fix the handling of the module parameters on both ends
so that users can choose to have fewer queues than p/vcpus if they like,
which would have been an effective workaround for the issue solved by
ca88ea1 if that hadn't been broken.

Thanks,
Ian.
