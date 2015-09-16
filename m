From: Hariprasad S <hariprasad@chelsio.com>
Subject: Re: [PATCHv2 net] cxgb4vf: support for single-threading access to
 adapter mailbox registers
Date: Wed, 16 Sep 2015 10:51:18 +0530
Message-ID: <20150916052117.GB13890@hariprasad-pc.asicdesigners.com>
References: <1442237914-9011-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:6890 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752009AbbIPFVZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2015 01:21:25 -0400
Content-Disposition: inline
In-Reply-To: <1442237914-9011-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 14, 2015 at 19:08:34 +0530, Hariprasad Shenai wrote:
> The issue is the for the Virtual Function Driver, the only way to get the
> Virtual Interface statistics is to issue mailbox commands to ask the
> firmware for the VI Stats. And, because the VI Stats command can only
> retrieve a smallish number of stats per mailbox command, we have to issue
> three mailbox commands in quick succession. What we ran into was irqbalance
> coming in every 10 seconds and interrogating every network interface in the
> system.
> 
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
> ---
> V2: Updated description and using linux completion API's instead of
>     for loop based on review comments by David Miller
> 
>  drivers/net/ethernet/chelsio/cxgb4vf/adapter.h     |  9 +++++
>  .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |  4 ++
>  drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c     | 46 +++++++++++++++++++++-
>  3 files changed, 58 insertions(+), 1 deletion(-)
> 


Hi David,

There is an issue with this patch. Can you please drop it.
Will send a V3, with the fixes. 

The below one should be a while loop, instead of if condition.
	/* If we're at the head, break out and start the mailbox
         * protocol.
         */
        if (list_first_entry(&adapter->mlist.list,
                             struct mbox_list, list) != &entry) {
                int ret;

Thanks
