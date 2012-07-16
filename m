From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Subject: Re: [PATCH] mlx4_en: map entire pages to increase throughput
Date: Mon, 16 Jul 2012 17:47:17 -0300
Message-ID: <20120716204717.GA16137@oc1711230544.ibm.com>
References: <1342458113-10384-1-git-send-email-cascardo@linux.vnet.ibm.com>
 <50044F1D.6000703@hp.com>
 <20120716190611.GA1023@oc1711230544.ibm.com>
 <50046EB1.5040909@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"yevgenyp@mellanox.co.il" <yevgenyp@mellanox.co.il>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"amirv@mellanox.com" <amirv@mellanox.com>,
	"brking@linux.vnet.ibm.com" <brking@linux.vnet.ibm.com>,
	"leitao@linux.vnet.ibm.com" <leitao@linux.vnet.ibm.com>,
	"klebers@linux.vnet.ibm.com" <klebers@linux.vnet.ibm.com>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"anton@samba.org" <anton@samba.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp01.br.ibm.com ([32.104.18.85]:57677 "EHLO
	e24smtp01.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752799Ab2GPUr2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2012 16:47:28 -0400
Received: from /spool/local
	by e24smtp01.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <cascardo@linux.vnet.ibm.com>;
	Mon, 16 Jul 2012 17:47:26 -0300
Received: from d24relay01.br.ibm.com (d24relay01.br.ibm.com [9.8.31.16])
	by d24dlp02.br.ibm.com (Postfix) with ESMTP id 4FF401DC004B
	for <netdev@vger.kernel.org>; Mon, 16 Jul 2012 16:47:22 -0400 (EDT)
Received: from d24av04.br.ibm.com (d24av04.br.ibm.com [9.8.31.97])
	by d24relay01.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6GKi2Tq2523162
	for <netdev@vger.kernel.org>; Mon, 16 Jul 2012 17:44:02 -0300
Received: from d24av04.br.ibm.com (loopback [127.0.0.1])
	by d24av04.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6GIlAda015812
	for <netdev@vger.kernel.org>; Mon, 16 Jul 2012 15:47:11 -0300
Content-Disposition: inline
In-Reply-To: <50046EB1.5040909@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 16, 2012 at 12:42:41PM -0700, Rick Jones wrote:
> On 07/16/2012 12:06 PM, Thadeu Lima de Souza Cascardo wrote:
> >On Mon, Jul 16, 2012 at 10:27:57AM -0700, Rick Jones wrote:
> >
> >>What is the effect on packet-per-second performance?  (eg aggregate,
> >>burst-mode netperf TCP_RR with TCP_NODELAY set or perhaps UDP_RR)
> >>
> >I used uperf with TCP_NODELAY and 16 threads sending from another
> >machine 64000-sized writes for 60 seconds.
> >
> >I get 5898op/s (3.02Gb/s) without the patch against 18022ops/s
> >(9.23Gb/s) with the patch.
> 
> I was thinking more along the lines of an additional comparison,
> explicitly using netperf TCP_RR or something like it, not just the
> packets per second from a bulk transfer test.
> 
> rick
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

I used a uperf profile that is similar to TCP_RR. It writes, then reads
some bytes. I kept the TCP_NODELAY flag.

Without the patch, I saw the following:

packet size	ops/s		Gb/s
1		337024		0.0027
90		276620		0.199
900		190455		1.37
4000		68863		2.20
9000		45638		3.29
60000		9409		4.52

With the patch:

packet size	ops/s		Gb/s
1		451738		0.0036
90		345682		0.248
900		272258		1.96
4000		127055		4.07
9000		106614		7.68
60000		30671		14.72
