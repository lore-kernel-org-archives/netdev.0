From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v2 02/15] i40evf: correctly program RSS HLUT table
Date: Wed, 19 Mar 2014 14:07:52 -0400 (EDT)
Message-ID: <20140319.140752.701088587181980100.davem@davemloft.net>
References: <1395200533-16908-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1395200533-16908-3-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mitch.a.williams@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, catherine.sullivan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37145 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750984AbaCSSHx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2014 14:07:53 -0400
In-Reply-To: <1395200533-16908-3-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 18 Mar 2014 20:42:00 -0700

> +#define NEXT_QUEUE(_j) (++_j >= adapter->vsi_res->num_queue_pairs ? _j = 0 : _j)

I would strong recommend breaking the increment out of the test
and using a function rather than a macro:

static int next_queue(struct i40evf_adapter *adapter, int j)
{
	j += 1;

	return j >= adapter->vsi_res->num_queue_pairs ? 0 : j;
}

 ..

	j = next_queue(adapter, j);
