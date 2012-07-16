From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] mlx4_en: map entire pages to increase throughput
Date: Mon, 16 Jul 2012 14:08:30 -0700
Message-ID: <500482CE.9000202@hp.com>
References: <1342458113-10384-1-git-send-email-cascardo@linux.vnet.ibm.com> <50044F1D.6000703@hp.com> <20120716190611.GA1023@oc1711230544.ibm.com> <50046EB1.5040909@hp.com> <20120716204717.GA16137@oc1711230544.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
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
To: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0187.atlanta.hp.com ([15.193.32.64]:6621 "EHLO
	g6t0187.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752291Ab2GPVIi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2012 17:08:38 -0400
In-Reply-To: <20120716204717.GA16137@oc1711230544.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I was thinking more along the lines of an additional comparison,
explicitly using netperf TCP_RR or something like it, not just the
packets per second from a bulk transfer test.

rick
--
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

> I used a uperf profile that is similar to TCP_RR. It writes, then reads
> some bytes. I kept the TCP_NODELAY flag.
>
> Without the patch, I saw the following:
>
> packet size	ops/s		Gb/s
> 1		337024		0.0027
> 90		276620		0.199
> 900		190455		1.37
> 4000		68863		2.20
> 9000		45638		3.29
> 60000		9409		4.52
>
> With the patch:
>
> packet size	ops/s		Gb/s
> 1		451738		0.0036
> 90		345682		0.248
> 900		272258		1.96
> 4000		127055		4.07
> 9000		106614		7.68
> 60000		30671		14.72
>

So, on the surface it looks like it did good things for PPS, though it 
would be nice to know what the CPU utilizations/service demands were as 
a sanity check - does uperf not have that sort of functionality?

I'm guessing there were several writes at a time - the 1 byte packet 
size (sic - that is payload, not packet, and without TCP_NODELAY not 
even payload necessarily) How many writes does it have outstanding 
before it does a read?  And does it take care to build-up to that number 
of writes to avoid batching during slowstart, even with TCP_NODELAY set?

rick jones
