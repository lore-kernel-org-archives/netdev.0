From: Haggai Eran <haggaie@mellanox.com>
Subject: Re: [PATCH 08/11] IB/cma: Add net_dev and private data checks to
 RDMA CM
Date: Tue, 16 Jun 2015 08:26:26 +0300
Message-ID: <557FB382.5090300@mellanox.com>
References: <1434358036-15526-1-git-send-email-haggaie@mellanox.com>
 <1434358036-15526-9-git-send-email-haggaie@mellanox.com>
 <20150615170837.GA14982@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Doug Ledford <dledford@redhat.com>, <linux-rdma@vger.kernel.org>,
	<netdev@vger.kernel.org>, Liran Liss <liranl@mellanox.com>,
	Guy Shapiro <guysh@mellanox.com>,
	Shachar Raindel <raindel@mellanox.com>,
	Yotam Kenneth <yotamke@mellanox.com>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0088.outbound.protection.outlook.com ([157.56.112.88]:63904
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752492AbbFPF1T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jun 2015 01:27:19 -0400
In-Reply-To: <20150615170837.GA14982@obsidianresearch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15/06/2015 20:08, Jason Gunthorpe wrote:
> On Mon, Jun 15, 2015 at 11:47:13AM +0300, Haggai Eran wrote:
>> Instead of relying on a the ib_cm module to check an incoming CM request's
>> private data header, add these checks to the RDMA CM module. This allows a
>> following patch to to clean up the ib_cm interface and remove the code that
>> looks into the private headers. It will also allow supporting namespaces in
>> RDMA CM by making these checks namespace aware later on.
> 
> I was expecting one of these patches to flow the net_device from here:
> 
>> +static struct net_device *cma_get_net_dev(struct ib_cm_event *ib_event,
>> +					  const struct cma_req_info *req)
>> +{
> 
> Down through cma_req_handler and cma_new_conn_id so that we get rid of
> the cma_translate_addr on the ingress side.
> 
> Having the ingress side use one ingress net_device for all processing
> seems very important to me...

Is it really very important? I thought the bound_dev_if of a passive
connection id is only used by the netlink statistics mechanism.

If you insist, I can set bound_dev_if based on the results of
cma_get_net_dev. That would cause the rdma_translate_ip call in
cma_translate_addr to exit early after calling rdma_copy_addr with the
chosen net_dev.

Haggai
