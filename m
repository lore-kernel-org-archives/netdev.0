From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Wrong UIDs reported in /proc/net/tcp
Date: Wed, 10 Nov 2004 10:18:56 +1100
Message-ID: <20041109231856.GA6152@gondor.apana.org.au>
References: <20041109205358.GA64015@calma.pair.com> <E1CRdBr-0001P2-00@gondolin.me.apana.org.au> <20041109224337.GB87321@calma.pair.com> <20041109225812.GA6001@gondor.apana.org.au> <20041109230411.GA91891@calma.pair.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: "Chad N. Tindel" <chad@tindel.net>
Content-Disposition: inline
In-Reply-To: <20041109230411.GA91891@calma.pair.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 09, 2004 at 06:04:11PM -0500, Chad N. Tindel wrote:
> 
> You're saying that since pidentd is calling fgets(), that can actually result
> in multiple read() calls.  Because of this, the first half of the line

fgets() is implemented on top of a buffered read, with my glibc it reads
4096 bytes.  Whatever that size is, the second read is most likely going
to be reading a partial record.  There is no guarantee that the partial
record is going to match the end of the first read.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
