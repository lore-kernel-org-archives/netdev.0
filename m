From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/packet: Fix Tx queue selection for
 AF_PACKET
Date: Mon, 03 Jul 2017 02:18:58 -0700 (PDT)
Message-ID: <20170703.021858.1360397700923467821.davem@davemloft.net>
References: <20170630210232.18407-1-ivan.briano@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, jesus.sanchez-palencia@intel.com,
        vinicius.gomes@intel.com, andre.guedes@intel.com
To: ivan.briano@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54636 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753459AbdGCJTM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Jul 2017 05:19:12 -0400
In-Reply-To: <20170630210232.18407-1-ivan.briano@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Iván Briano <ivan.briano@intel.com>
Date: Fri, 30 Jun 2017 14:02:32 -0700

> When PACKET_QDISC_BYPASS is not used, Tx queue selection will be done
> before the packet is enqueued, taking into account any mappings set by
> a queuing discipline such as mqprio without hardware offloading. This
> selection may be affected by a previously saved queue_mapping, either on
> the Rx path, or done before the packet reaches the device, as it's
> currently the case for AF_PACKET.
> 
> In order for queue selection to work as expected when using traffic
> control, there can't be another selection done before that point is
> reached, so move the call to packet_pick_tx_queue to
> packet_direct_xmit, leaving the default xmit path as it was before
> PACKET_QDISC_BYPASS was introduced.
> 
> A forward declaration of packet_pick_tx_queue() is introduced to avoid
> the need to reorder the functions within the file.
> 
> Signed-off-by: Iván Briano <ivan.briano@intel.com>

Please resubmit tihs with a proper "Fixes: " tag which shows what
commit introduced this problem.

Thanks.
