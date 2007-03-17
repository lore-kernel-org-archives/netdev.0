From: takada <takada@mbf.nifty.com>
Subject: Re: MediaGX/GeodeGX1 requires X86_OOSTORE.
Date: Sat, 17 Mar 2007 22:08:10 +0900 (JST)
Message-ID: <20070317.220810.208970218.takada@mbf.nifty.com>
References: <20070220144823.GN7585@csclub.uwaterloo.ca>
	<20070315.143939.193680310.takada@mbf.nifty.com>
	<20070315173137.GJ22466@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, pcnet32@verizon.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: lsorense@csclub.uwaterloo.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from pxy2nd.nifty.com ([202.248.175.14]:52646 "HELO pxy2nd.nifty.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S933821AbXCQNLq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Mar 2007 09:11:46 -0400
In-Reply-To: <20070315173137.GJ22466@csclub.uwaterloo.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: MediaGX/GeodeGX1 requires X86_OOSTORE.
Date: Thu, 15 Mar 2007 13:31:37 -0400

> On Thu, Mar 15, 2007 at 02:39:39PM +0900, takada wrote:
> > Hiroshi Miura posted `Geode out-of-order store enables' patch in Jun, 2003.
> > There is http://lkml.org/lkml/2003/6/5/57 .
> > OOSTORE was enabled at this point in time. It seems to have disappeared somewhere.
> 
> I believe the patch was rejected as 'not required' since the data sheet
> is not very clear on that "feature".

Is it http://lkml.org/lkml/2003/6/5/85 you mean?
It seems not to be surely written in data sheet that OOSTORE is necessary. But Geode
reorder memory access.

> > BTW, I use MediaGX with kernel 2.6.20(and 2.6.20.3) and suspend2. When I resume 
> > the PC and use the PC Card modem, PC is hungup. However, PC isn't hung up when
> > I apply a WBINVD patch.
> > I can't understand it whether there is problem in resume of suspend2 or MediaGX
> > or both. Many drivers lack support for resume on my PC.
> 
> Which patch are you refering to?

I tested some patterns. just X86_OOSTORE was effective. WBINVD is needless.

--- arch/i386/Kconfig.cpu~	2007-02-05 03:44:54.000000000 +0900
+++ arch/i386/Kconfig.cpu	2007-02-17 21:25:52.000000000 +0900
@@ -322,7 +322,7 @@ config X86_USE_3DNOW
 
 config X86_OOSTORE
 	bool
-	depends on (MWINCHIP3D || MWINCHIP2 || MWINCHIPC6) && MTRR
+	depends on (MWINCHIP3D || MWINCHIP2 || MWINCHIPC6) && MTRR || MGEODEGX1
 	default y
 
 config X86_TSC



