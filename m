From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH 1/4] sctp: Fix crc32c calculations on big-endian arhes.
Date: Fri, 23 Jan 2009 09:52:44 -0500
Message-ID: <4979D9BC.5000609@hp.com>
References: <1232663768-4028-2-git-send-email-vladislav.yasevich@hp.com> <20090123051956.GA25803@gondor.apana.org.au> <20090123052849.GA25937@gondor.apana.org.au> <20090123092449.GA27399@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	davem@davemloft.net
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:46447 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751185AbZAWOwr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2009 09:52:47 -0500
In-Reply-To: <20090123092449.GA27399@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Fri, Jan 23, 2009 at 04:28:49PM +1100, Herbert Xu wrote:
>>>> static inline __be32 sctp_end_cksum(__be32 crc32)
>>>> {
>>>> -       return ~crc32;
>>>> +       return (__force __be32)~cpu_to_le32((__force u32)crc32);
>>>> }
>>> Ouch, surely there is a better way to do this?
>> In fact this looks wrong.  Has this code actually been tested
>> on big-endian?

Yes, the code was tested by me and the person who reported it
as listed in the commit log. :)

> 
> Reading this again it does seem to do the right thing as it's
> using the raw crc32c interface as opposed to crypto crc32c.
> 
> However, I suggest that we change it as follows:
> 
> 1) Make sh->csum __le32 since we're using crc32c_le.
> 2) Change all intermediate values in sctp/checksum.h to u32.
> 3) Make sctp_end_cksum return __le32 and have it do
> 
> 	return cpu_to_le32(~crc);
> 

I'll give it some thought.  It would clean up all the __force
casts, but it will be a little misleading to define a packet
checksum as little endian. :)

-vlad

> Cheers,
