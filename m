From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v3] net: Do not include padding in TCP GRO checksum
Date: Sun, 17 Nov 2013 10:24:36 -0800
Message-ID: <528909E4.1000100@gmail.com>
References: <20131115225856.6988.69733.stgit@ahduyck-fpga.jf.intel.com> <20131116004738.GA1491@gondor.apana.org.au> <20131116015301.GA1999@gondor.apana.org.au> <5286F018.8060801@gmail.com> <20131116064611.GA12146@gondor.apana.org.au> <5287A52A.2060802@gmail.com> <20131117031710.GA18254@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>, davem@davemloft.net,
	netdev@vger.kernel.org, edumazet@google.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:46087 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751864Ab3KQSYl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Nov 2013 13:24:41 -0500
Received: by mail-pb0-f41.google.com with SMTP id jt11so5748198pbb.0
        for <netdev@vger.kernel.org>; Sun, 17 Nov 2013 10:24:41 -0800 (PST)
In-Reply-To: <20131117031710.GA18254@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/16/2013 07:17 PM, Herbert Xu wrote:
> On Sat, Nov 16, 2013 at 09:02:34AM -0800, Alexander Duyck wrote:
>> That being the case though, why don't we set the flush flag on detecting
>> a bad checksum and hand it off to tcp_gro_receive instead of returning
>> NULL?  It seems like it would be in our interest to flush the flow and
>> then report the bad checksum instead of keeping the flow and handing off
>> the bad checksum to the stack.
> Because if the TCP checksum is wrong then it may belong to a
> different flow.
>
> Cheers,

It seems like it would be much more likely that a checksum error
occuring with a padded frame would corrupt the flow identifying data
then one that isn't padded.

I suppose it doesn't really matter though since checksum errors are
probably not going to be all that common of a case to deal with anyway.

Thanks,

Alex
