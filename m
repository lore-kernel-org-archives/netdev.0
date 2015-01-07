From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH net-next v2 6/7] rhashtable: initialize atomic nelems
 variable
Date: Wed, 7 Jan 2015 18:26:21 +0800
Message-ID: <54AD09CD.3010100@windriver.com>
References: <1420609318-3261-1-git-send-email-ying.xue@windriver.com> <1420609318-3261-7-git-send-email-ying.xue@windriver.com> <20150107095332.GK21820@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <jon.maloy@ericsson.com>,
	<Paul.Gortmaker@windriver.com>, <erik.hugne@ericsson.com>,
	<netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:58230 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752093AbbAGK1F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 05:27:05 -0500
In-Reply-To: <20150107095332.GK21820@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/07/2015 05:53 PM, Thomas Graf wrote:
> On 01/07/15 at 01:41pm, Ying Xue wrote:
>> Signed-off-by: Ying Xue <ying.xue@windriver.com>
>> Cc: Thomas Graf <tgraf@suug.ch>
> 
> Is this really needed at all? We initialize the full rhashtable
> struct to 0 in rhashtable_init().
> 
> 

I am not sure whether we really need to reinitialize atomic variable
again although we have reset it with memset() or something else. But I
see many places in kernel where we do this, for example:

Although we use kmem_cache_zalloc() to allocate "net" structure instance
in net_alloc(), there are still several places where to reinitialize its
atomic variables again:

setup_net()
  atomic_set(&net->use_count, 0);

rt_genid_init()
  atomic_set(&net->ipv4.rt_genid, 0);
  atomic_set(&net->fnhe_genid, 0);

Can you please definitely confirm that the reinitialisation is redundant
for us?

Regards,
Ying
