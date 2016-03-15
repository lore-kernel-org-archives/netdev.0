From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH v2 net-next] rds-tcp: Add sysctl tunables for
 sndbuf/rcvbuf on rds-tcp socket
Date: Tue, 15 Mar 2016 14:16:29 -0400
Message-ID: <20160315181629.GO11063@oracle.com>
References: <20160315151248.GJ11063@oracle.com>
 <56E83A6D.6060904@oracle.com>
 <20160315165800.GL11063@oracle.com>
 <1458062294.31401.37.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160315173011.GM11063@oracle.com>
 <1458065390.31401.45.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: santosh shilimkar <santosh.shilimkar@oracle.com>,
	netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:30245 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932212AbcCOSQi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2016 14:16:38 -0400
Content-Disposition: inline
In-Reply-To: <1458065390.31401.45.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (03/15/16 11:09), Eric Dumazet wrote:
> 
> You said "just as user-space SO_SNDBUF allows ridiculous values
> for buffer size.."
> 
> So I understood you believe SOCK_MIN_SNDBUF and/or SOCK_MIN_RCVBUF are
> ridiculous ;)

No, no! I was saying that as a clueless user-space app, I can SO_SNDBUF
to 1, and happily think that everything is fine (error == 0), when in
reality the kernel has helpfully fixed up the value for me..

> I pointed to you the actual code.
> 
> sk->sk_sndbuf = max_t(u32, val * 2, SOCK_MIN_SNDBUF);

yes, I'm in the process of changing rds-tcp now (doing sanity tests
etc on it, will send out update in a short while)

> 
> 
> No error is returned. kernel enforces a minimal value.
> 
> #define SOCK_MIN_SNDBUF         (TCP_SKB_MIN_TRUESIZE * 2)
> #define TCP_SKB_MIN_TRUESIZE    (2048 + SKB_DATA_ALIGN(sizeof(struct
> sk_buff)))
> 
> -> 2 * (2048 + 256) = 4608  given current sk_buff overhead (that might
> change in linux 5.4 ... )

Yes, I've seen the comments somewhere (in sock_setsockopt?)

it's a bit unexpectd for someone coming from bsd/solaris because
the value returned by getsockopt is quite unpredictable (as you
point out, depends on the kernel version among other things).

> But again if your sysctl allows to set a value below SOCK_MIN_SNDBUF,
> that might be a problem, because stack could have a hidden bug for very
> small values of sndbuf/rcvbuf. 

sure, fixing/testing it as I write this.

--Sowmini
