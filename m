From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Where exactly will arch_fast_hash be used
Date: Mon, 08 Dec 2014 17:32:09 +0100
Message-ID: <1418056329.279341.200273721.1C7A7F3E@webmail.messagingengine.com>
References: <20141208161959.8852.qmail@ns.horizon.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, dborkman@redhat.com,
	herbert@gondor.apana.org.au, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, tgraf@suug.ch, tytso@mit.edu
To: George Spelvin <linux@horizon.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:56568 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752195AbaLHQcK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 11:32:10 -0500
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 2B0B420952
	for <netdev@vger.kernel.org>; Mon,  8 Dec 2014 11:32:10 -0500 (EST)
In-Reply-To: <20141208161959.8852.qmail@ns.horizon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Mon, Dec 8, 2014, at 17:19, George Spelvin wrote:
> >>> In case of openvswitch it shows a performance improvment. The seed
> >>> parameter could be used as an initial biasing of the crc32 function, but
> >>> in case of openvswitch it is only set to 0.
>  
> >> NACK. [...]
> 
> > Sorry for being unclear, I understood that and didn't bother patching
> > that '0' with a random seed exactly because of this.
> 
> And I'm sorry for delivering a long lecture on a subject you already
> understood perfectly well.

I learned something, so your time wasn't completely wasted. ;)

> I'd just been thinking about it because of Herbert's comments, so it was
> conveniently at hand. :-)
> 
> Out of curiousity, what *were* you referring to when you talked
> about biasing the crc32 function?  "Biasing" is a good term becuase
> it just applies an offset, but what do you gain from doing that?

Actually, I don't know why the seed parameter was added. I just wanted
to mention that there is a way to bias the crc32 function which fits
into the style of the other hashing functions, like jhash with its
initval parameter.

I just kept it around during the rewrite.

The only use case I can imagine would be if one would like to calculate
a crc32c over a non-contiguous array, thus feeding the result of one crc
operation into the next one.

> There are nifty things one can do with the CRC32 instruction, however.
> A lot of ciphers these days use an ARX (add, rotate, XOR) kernel.
> A crc32 instruction, although linear, does some very powerful rotate &
> xor operations, and could replace the XOR and rotate.

Yes, I have seen it being used in cityhash.

There is also a proposal by Intel, but the hash seems too weak, too:
http://www.intel.com/content/dam/www/public/us/en/documents/white-papers/hash-method-performance-paper.pdf

Bye,
Hannes
