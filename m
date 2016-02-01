From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next] netfilter: nf_conntrack: remove the unneed
 check for *bucket
Date: Mon, 1 Feb 2016 16:39:56 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CCD2594@AcuExch.aculab.com>
References: <56ACABBC.9050303@huawei.com>
 <20160130213003.GA13560@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "pablo@netfilter.org" <pablo@netfilter.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"kadlec@blackhole.kfki.hu" <kadlec@blackhole.kfki.hu>,
	David Miller <davem@davemloft.net>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"coreteam@netfilter.org" <coreteam@netfilter.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: 'Florian Westphal' <fw@strlen.de>,
	Weidong Wang <wangweidong1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.194]:56383 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753684AbcBAQnQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2016 11:43:16 -0500
In-Reply-To: <20160130213003.GA13560@breakpoint.cc>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal
> Sent: 30 January 2016 21:30
> Weidong Wang <wangweidong1@huawei.com> wrote:
> > In the 'for(...) {}', the *bucket alwasy < net->ct.htable_size,
> > so remove the check
> > @@ -1383,14 +1383,12 @@ get_next_corpse(struct net *net, int (*iter)(struct nf_conn *i, void *data),
> >  		lockp = &nf_conntrack_locks[*bucket % CONNTRACK_LOCKS];
> >  		local_bh_disable();
> >  		spin_lock(lockp);
> > -		if (*bucket < net->ct.htable_size) {
> 
> AFAIU net->ct.htable_size can shrink between for-test and aquiring
> the bucket lockp, so this additional if-test is needed.

If the table can shrink, can it not also grow - in which case
the references bucket will be incorrect?

	David
