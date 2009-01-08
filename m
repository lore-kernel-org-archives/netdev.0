From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bugme-new] [Bug 12327] New: Intermittent TCP issues with =>
	2.6.27
Date: Thu, 8 Jan 2009 14:07:45 +1100
Message-ID: <20090108030745.GA1204@gondor.apana.org.au>
References: <bug-12327-10286@http.bugzilla.kernel.org/> <20081229214101.4c4f5ac1.akpm@linux-foundation.org> <Pine.LNX.4.64.0812311241490.3120@wrl-59.cs.helsinki.fi> <495BFEAF.6000006@haveacry.com> <20090102083402.GA24383@gondor.apana.org.au> <4961ECD2.1000502@haveacry.com> <20090107041732.GA22041@gondor.apana.org.au> <4964B303.4020708@haveacry.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Netdev <netdev@vger.kernel.org>,
	bugme-daemon@bugzilla.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Speedster <speedster@haveacry.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:38872 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751677AbZAHDIA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2009 22:08:00 -0500
Content-Disposition: inline
In-Reply-To: <4964B303.4020708@haveacry.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 07, 2009 at 10:49:55PM +0900, Speedster wrote:
>
> Done. I also realised my wireshark display filter was dst_host rather  
> than simply host - it looks as though replies _do_ come back but for  
> some reason are ignored? My apologies.

Great I think we're getting closer.  With your latest dumps it'd
appear that there is an odd difference between the replies that
get through and the ones that don't.  The ones that're somehow
dropped have 2 bytes of transport padding at the end.  I suspect
there's something buggy in your system that's dropping it because
of this.

Can you please take a look at /proc/net/snmp on the host and the
guest to see if IP InDiscards is non-zero?

Also now that we know the problem is definitely in the host/guest
please take another set of dumps on the interfaces leading to and
within the guest to see exactly which path of the system is dropping
the reply.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
