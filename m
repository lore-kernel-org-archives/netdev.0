From: Juergen Gross <jgross@suse.com>
Subject: Re: [PATCH v2] xen-netfront: Fix Rx stall during network stress and
 OOM
Date: Mon, 16 Jan 2017 07:24:05 +0100
Message-ID: <ee87b2e4-de8c-7b9b-c4e5-854ffab2e554@suse.com>
References: <0cb06b48-cb3c-47aa-2ae6-3a70197a5b64@amazon.com>
 <1484330100-3960-1-git-send-email-vineethp@u480fcf3b67f557f68df1.ant.amazon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Vineeth Remanan Pillai <vineethp@amazon.com>, kamatam@amazon.com,
        aliguori@amazon.com
To: Remanan Pillai <vineethp@u480fcf3b67f557f68df1.ant.amazon.com>,
        boris.ostrovsky@oracle.com, xen-devel@lists.xenproject.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:36077 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750845AbdAPGYI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 16 Jan 2017 01:24:08 -0500
In-Reply-To: <1484330100-3960-1-git-send-email-vineethp@u480fcf3b67f557f68df1.ant.amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13/01/17 18:55, Remanan Pillai wrote:
> From: Vineeth Remanan Pillai <vineethp@amazon.com>
> 
> During an OOM scenario, request slots could not be created as skb
> allocation fails. So the netback cannot pass in packets and netfront
> wrongly assumes that there is no more work to be done and it disables
> polling. This causes Rx to stall.
> 
> The issue is with the retry logic which schedules the timer if the
> created slots are less than NET_RX_SLOTS_MIN. The count of new request
> slots to be pushed are calculated as a difference between new req_prod
> and rsp_cons which could be more than the actual slots, if there are
> unconsumed responses.
> 
> The fix is to calculate the count of newly created slots as the
> difference between new req_prod and old req_prod.
> 
> Signed-off-by: Vineeth Remanan Pillai <vineethp@amazon.com>

Reviewed-by: Juergen Gross <jgross@suse.com>


Thanks,

Juergen
