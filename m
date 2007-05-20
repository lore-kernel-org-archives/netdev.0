From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bugme-new] [Bug 8491] New: OOPS triggered by ip(8) deconfiguring a network interface
Date: Sun, 20 May 2007 20:26:26 +1000
Message-ID: <E1HpicM-0006eE-00@gondolin.me.apana.org.au>
References: <20070517101608.57466a59.akpm@linux-foundation.org>
Cc: netdev@vger.kernel.org, bcollins@ubuntu.com,
	bugme-daemon@bugzilla.kernel.org
To: akpm@linux-foundation.org (Andrew Morton)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1062 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755568AbXETK0j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 May 2007 06:26:39 -0400
In-Reply-To: <20070517101608.57466a59.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton <akpm@linux-foundation.org> wrote:
>
> [43092.388000] Stack: e30f433c cab60000 c028608e 00000000 e2e8ae40 00000000 e2e8a5c0 dfe0aa58 
> [43092.388000]        c826ca00 c826ca00 f10a72ff f1088989 00a33d71 000080fe 00000000 00000001 
> [43092.388000]        cab60000 e2e8a5c0 dfe0aa58 00000000 c826ca00 f1089594 c826ca54 00000040 
> [43092.388000] Call Trace:
> [43092.388000]  [<c028608e>] pneigh_queue_purge+0x1e/0x30
> [43092.388000]  [<f10a72ff>] snmp6_unregister_dev+0x2f/0x40 [ipv6]

Looks like a problem with your resume.  The second argument to
remove_proc_entry, parent, has the value 00a33d71 which is clearly
bogus.  That value in turn comes from proc_net_devsnmp6.  So somehow
during the suspend/resume that pointer has been corrupted.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
