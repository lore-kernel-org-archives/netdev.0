From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [Fwd: Re: [PATCH v2 2/2] x86: add prefetching to do_csum]
Date: Wed, 13 Nov 2013 10:09:51 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B740E@saturn3.aculab.com>
References: <1384220542.4771.23.camel@joe-AO722> <20131112171239.GC19780@hmsreliant.think-freely.org> <1384277615.3665.10.camel@joe-AO722> <20131112195005.GD19780@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev" <netdev@vger.kernel.org>, "Dave Jones" <davej@redhat.com>,
	<linux-kernel@vger.kernel.org>, <sebastien.dugue@bull.net>,
	"Thomas Gleixner" <tglx@linutronix.de>,
	"Ingo Molnar" <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>,
	<x86@kernel.org>, "Eric Dumazet" <eric.dumazet@gmail.com>
To: "Neil Horman" <nhorman@tuxdriver.com>,
	"Joe Perches" <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:35911 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1758631Ab3KMKK4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 05:10:56 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 14838-03 for <netdev@vger.kernel.org>;
 Wed, 13 Nov 2013 10:10:53 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <20131112195005.GD19780@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Sure, I modified the code so that we only prefetched 2 cache lines ahead, but
> only if the overall length of the input buffer is more than 2 cache lines.
> Below are the results (all counts are the average of 1000000 iterations of the
> csum operation, as previous tests were, I just omitted that column).

Hmmm.... averaging over 100000 iterations means that all the code
is in the i-cache and the branch predictor will be correctly primed.

For short checksum requests I'd guess that the relevant data
has just been written and is already in the cpu cache (unless
there has been a process and cpu switch).
So prefetch is likely to be unnecessary.

If you assume that the checksum code isn't in the i-cache then
small requests are likely to be dominated by the code size.

	David
