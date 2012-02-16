From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: Re: [PATCH] vmxnet3: cap copy length at size of skb to prevent
 dropped frames on tx
Date: Thu, 16 Feb 2012 12:07:02 -0800 (PST)
Message-ID: <19987954.351014.1329422822704.JavaMail.root@zimbra-prod-mbox-5.vmware.com>
References: <1329392936-14548-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Max Matveev <mmatveev@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	"VMware, Inc." <pv-drivers@vmware.com>, netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([208.91.2.12]:43340 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753030Ab2BPUOG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2012 15:14:06 -0500
In-Reply-To: <1329392936-14548-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Also, since I'm unable to do this, it wuold be great if vmware could
> follow up
> this patch with some additional code commentary as to why 54 bytes is
> an optimal
> pull length for a virtual NIC driver.  The comment that introduced
> this was
> vague on that.  Thanks!


Neil, thanks for the patch. We fixed this bug in local repositories
recently and I was about to post a patch to LKML. As for the explanation,
the vNIC is optimized to work with most frequently occurring headers(TCP)
and hence needs particular number of bytes in first sg. Even in case of
UDP this pull is cheaper (CPU utilization wise) to do in guest than in
device emulation.

Signed-off-by: Shreyas N Bhatewara <sbhatewara@vmware.com>
