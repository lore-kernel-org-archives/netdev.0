From: Chris Wedgwood <cw@f00f.org>
Subject: Re: [PATCH] Disable multipath cache routing
Date: Sat, 20 May 2006 13:51:45 -0700
Message-ID: <20060520205145.GB32010@taniwha.stupidest.org>
References: <446ED597.20300@calsoftinc.com> <446EE440.8000808@calsoftinc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Suresh Bhogavilli <sbhogavilli@verisign.com>,
	Julian Anastasov <ja@ssi.bg>, Ilia Sotnikov <hostcc@gmail.com>,
	netdev@vger.kernel.org, Einar Lueck <elueck@de.ibm.com>,
	lkml@einar-lueck.de, Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp110.sbc.mail.mud.yahoo.com ([68.142.198.209]:13656 "HELO
	smtp110.sbc.mail.mud.yahoo.com") by vger.kernel.org with SMTP
	id S1751488AbWETUvs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 May 2006 16:51:48 -0400
To: pravin b shelar <pravin.shelar@calsoftinc.com>
Content-Disposition: inline
In-Reply-To: <446EE440.8000808@calsoftinc.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(cc' list exploded to include various people who might not be reading
     netdev, sorry about that)

On Sat, May 20, 2006 at 03:11:20PM +0530, pravin b shelar wrote:
> I am working on Linux multipath networking and I will like to fix
> bugs related to equal cost multipath caching support.

My experience here is limited to having been using as and finding it
was creating erroneous routes which DaveM correctly guessed was the
result of CONFIG_IP_MULTIPATH_CACHED being enabled.

Looking over ipv4/route.c there is a fair bit of complex code to audit
(fib_semantics.c also needs to be checked, but it's not very involved)
so perhaps if you or someone else who understand this code well is
interested that would be a good place to start a code audit?

I see also a patch from Herbert Xu about disabling this on the input
path (the patch isn't present in the tree right now, I'm not sure if
it was revert/fixed or just never merged).  Perhaps he can also point
out what wrong here?

  http://oss.sgi.com/archives/netdev/2005-04/msg00232.html

Anyhow, the code as-is hasn't been maintained for a long time except
for a few minor blips (I'm using hg's annotate to find those and have
included those people on the cc' list as presumably there are using
these features and might have useful input).
