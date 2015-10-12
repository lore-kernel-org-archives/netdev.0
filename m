From: Ido Schimmel <idosch@mellanox.com>
Subject: Re: [PATCH net-next 4/4] bridge: vlan: combine (br|nbp)_vlan_flush
 into one
Date: Mon, 12 Oct 2015 20:51:56 +0300
Message-ID: <20151012175156.GA16784@colbert.mtl.com>
References: <1444650069-32572-1-git-send-email-razor@blackwall.org>
 <1444650069-32572-5-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <shm@cumulusnetworks.com>,
	<roopa@cumulusnetworks.com>, <stephen@networkplumber.org>,
	<bridge@lists.linux-foundation.org>, <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Nikolay Aleksandrov <razor@blackwall.org>, <sfeldma@gmail.com>,
	<vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0073.outbound.protection.outlook.com ([157.55.234.73]:50309
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752018AbbJLRwI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Oct 2015 13:52:08 -0400
Content-Disposition: inline
In-Reply-To: <1444650069-32572-5-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Oct 12, 2015 at 02:41:09PM IDT, razor@blackwall.org wrote:
>From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>
>As Ido Schimmel pointed out the vlan_vid_del() loop in nbp_vlan_flush is
>unnecessary (and is actually a remnant of the old vlan code) so we can
>remove it and combine both br/nbp vlan_flush functions into one.
Just a small note to Scott and Vivien:

One of the side effects of Nik's recent patchsets is that when VLANs are
flushed on a port the deletion is propagated to the driver via
switchdev ops, as __vlan_vid_del is called.

Therefore there is no need to do internal bookkeeping and remove VLANs
yourself when port is removed from bridge.
>
>Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
