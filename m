From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: [PANIC] lro + iscsi or lro + skb text search causes panic
Date: Mon, 26 Jan 2009 17:40:08 -0800
Message-ID: <F169D4F5E1F1974DBFAFABF47F60C10A1C225135@orsmsx507.amr.corp.intel.com>
References: <alpine.WNT.2.00.0901221234420.4188@jbrandeb-desk1.amr.corp.intel.com>
 <20090122232131.GA22771@gondor.apana.org.au> <4979097B.4040108@cs.wisc.edu>
 <20090125.213222.192571170.davem@davemloft.net>
 <20090126223022.GA24046@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "michaelc@cs.wisc.edu" <michaelc@cs.wisc.edu>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tgraf@suug.ch" <tgraf@suug.ch>, "kkeil@suse.de" <kkeil@suse.de>
To: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:54490 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750989AbZA0BkK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 20:40:10 -0500
In-Reply-To: <20090126223022.GA24046@gondor.apana.org.au>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Sun, Jan 25, 2009 at 09:32:22PM -0800, David Miller wrote:
>> From: Mike Christie <michaelc@cs.wisc.edu>
>> Date: Thu, 22 Jan 2009 18:04:11 -0600
>> 
>>> With the patch running against linus's git tree, my box locks
>>> up. You cannot ping it. I do not get a oops or anything in the logs,
>>> and the keyboard does not respond. I will try to get some oops
>>> output and more info.
>> 
>> Herbert, any idea offhand?
> 
> Yeah, I missed an offset update in there :) Here's a better version.
> 
> net: Fix frag_list handling in skb_seq_read
> 
> The frag_list handling was broken in skb_seq_read:
> 
> 1) We didn't add the stepped offset when looking at the head
> are of fragments other than the first.
> 
> 2) We didn't take the stepped offset away when setting the data
> pointer in the head area.
> 
> 3) The frag index wasn't reset.
> 
> This patch fixes both issues.

1-3 (both, :-)) doesn't seem to work here, I applied this and still got a 
panic when doing a quick test before I went home today.

I can get panic trace from netconsole tomorrow.