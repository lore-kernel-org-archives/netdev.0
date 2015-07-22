From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net] net: sctp: stop spamming klog with rfc6458, 5.3.2.
 deprecation warnings
Date: Wed, 22 Jul 2015 10:43:40 -0400
Message-ID: <55AFAC1C.7090000@mojatatu.com>
References: <04fbd47379461dc2cb145117a9f81ecc68de7221.1437575142.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com, nhorman@tuxdriver.com,
	David.Laight@ACULAB.COM, netdev@vger.kernel.org,
	Michael Tuexen <tuexen@fh-muenster.de>
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:38498 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932693AbbGVOnt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 10:43:49 -0400
Received: by wibxm9 with SMTP id xm9so106045008wib.1
        for <netdev@vger.kernel.org>; Wed, 22 Jul 2015 07:43:48 -0700 (PDT)
In-Reply-To: <04fbd47379461dc2cb145117a9f81ecc68de7221.1437575142.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/22/15 10:31, Daniel Borkmann wrote:
> Back then when we added support for SCTP_SNDINFO/SCTP_RCVINFO from
> RFC6458 5.3.4/5.3.5, we decided to add a deprecation warning for the
> (as per RFC deprecated) SCTP_SNDRCV via commit bbbea41d5e53 ("net:
> sctp: deprecate rfc6458, 5.3.2. SCTP_SNDRCV support"), see [1].
>
> Imho, it was not a good idea, and we should just revert that message
> for a couple of reasons:
>
>    1) It's uapi and therefore set in stone forever.
>
>    2) To be able to run on older and newer kernels, an SCTP application
>       would need to probe for both, SCTP_SNDRCV, but also SCTP_SNDINFO/
>       SCTP_RCVINFO support, so that on older kernels, it can make use
>       of SCTP_SNDRCV, and on newer kernels SCTP_SNDINFO/SCTP_RCVINFO.
>       In my (limited) experience, a lot of SCTP appliances are migrating
>       to newer kernels only ve(ee)ry slowly.
>
>    3) Some people don't have the chance to change their applications,
>       f.e. due to proprietary legacy stuff. So, they'll hit this warning
>       in fast path and are stuck with older kernels.
>
> But i.e. due to point 1) I really fail to see the benefit of a warning.
> So just revert that for now, the issue was reported up Jamal.
>
>    [1] http://thread.gmane.org/gmane.linux.network/321960/
>
> Reported-by: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Cc: Michael Tuexen <tuexen@fh-muenster.de>


Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
