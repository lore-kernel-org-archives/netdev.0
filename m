From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: sctp: stop spamming klog with rfc6458, 5.3.2.
 deprecation warnings
Date: Sun, 26 Jul 2015 16:32:59 -0700 (PDT)
Message-ID: <20150726.163259.1952188676271532807.davem@davemloft.net>
References: <04fbd47379461dc2cb145117a9f81ecc68de7221.1437575142.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, vyasevic@redhat.com, nhorman@tuxdriver.com,
	David.Laight@ACULAB.COM, netdev@vger.kernel.org,
	tuexen@fh-muenster.de
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36721 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755092AbbGZXdA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jul 2015 19:33:00 -0400
In-Reply-To: <04fbd47379461dc2cb145117a9f81ecc68de7221.1437575142.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Wed, 22 Jul 2015 16:31:49 +0200

> Back then when we added support for SCTP_SNDINFO/SCTP_RCVINFO from
> RFC6458 5.3.4/5.3.5, we decided to add a deprecation warning for the
> (as per RFC deprecated) SCTP_SNDRCV via commit bbbea41d5e53 ("net:
> sctp: deprecate rfc6458, 5.3.2. SCTP_SNDRCV support"), see [1].
> 
> Imho, it was not a good idea, and we should just revert that message
> for a couple of reasons:
> 
>   1) It's uapi and therefore set in stone forever.
> 
>   2) To be able to run on older and newer kernels, an SCTP application
>      would need to probe for both, SCTP_SNDRCV, but also SCTP_SNDINFO/
>      SCTP_RCVINFO support, so that on older kernels, it can make use
>      of SCTP_SNDRCV, and on newer kernels SCTP_SNDINFO/SCTP_RCVINFO.
>      In my (limited) experience, a lot of SCTP appliances are migrating
>      to newer kernels only ve(ee)ry slowly.
> 
>   3) Some people don't have the chance to change their applications,
>      f.e. due to proprietary legacy stuff. So, they'll hit this warning
>      in fast path and are stuck with older kernels.
> 
> But i.e. due to point 1) I really fail to see the benefit of a warning.
> So just revert that for now, the issue was reported up Jamal.
> 
>   [1] http://thread.gmane.org/gmane.linux.network/321960/
> 
> Reported-by: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied, thanks Daniel.
