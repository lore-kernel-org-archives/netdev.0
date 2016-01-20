From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: net: GPF in __netlink_ns_capable
Date: Wed, 20 Jan 2016 23:00:20 +0800
Message-ID: <20160120150020.GA25156@gondor.apana.org.au>
References: <CACT4Y+bS-hDuTWtXTR-n8i+tqkFcCYUxnj0QK3JsyWn25FzVRg@mail.gmail.com>
 <CAFLxGvzo6NRNsHsJwys6c+oSMUpQxdfDEkWG-qaSqqP=V3Sjdw@mail.gmail.com>
 <20160118092047.GA30682@gondor.apana.org.au>
 <878u3m7i5q.fsf@x220.int.ebiederm.org>
 <87vb6q63co.fsf@x220.int.ebiederm.org>
 <3F128C9216C9B84BB6ED23EF16290AFB185A437D@CRSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Richard Weinberger <richard.weinberger@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Ken-ichirou MATSUZAWA <chamaken@gmail.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Florian Westphal <fw@strlen.de>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Eric Dumazet <edumazet@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	"Fleck, John" <john.fleck@intel.com>,
	"Weiny, Ira" <ira.weiny@intel.com>,
	Doug Ledford <dledford@redhat.com>,
	Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: "Wan, Kaike" <kaike.wan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:59378 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751367AbcATPBH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 10:01:07 -0500
Content-Disposition: inline
In-Reply-To: <3F128C9216C9B84BB6ED23EF16290AFB185A437D@CRSMSX101.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 20, 2016 at 02:35:59PM +0000, Wan, Kaike wrote:
> >From the code (netlink_dump() in net/netlink/af_netlink.c), it shows that a skb is allocated without initializing the skb->cb[] field, which will cause oops if netlink_capable() is called with the duplicate skb. This will happen if the netlink_dump_start() path is followed (in ibnl_rcv_msg() in drivers/infiniband/core/netlink.c). However, for the IB netlink local service, we handle only request RDMA_NL_LS_OP_SET_TIMEOUT and response to RDMA_NL_LS_OP_RESOLVE, which directly call the registered dump function (ib_nl_handle_resolve_resp() and ib_nl_handle_resolve_resp()). See the following snippet:

You'll find a reproducer in the original email:

http://lkml.iu.edu/hypermail/linux/kernel/1601.1/06505.html

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
