From: Nikos Mavrogiannopoulos <nmav@gnutls.org>
Subject: Re: RFC: Crypto API User-interface
Date: Wed, 20 Oct 2010 12:24:33 +0200
Message-ID: <AANLkTi=cmus+1fWBbqH8p=cw4G60+PF_572=5Au=TDxL@mail.gmail.com>
References: <20100907084213.GA4610@gondor.apana.org.au>
	<20101019134418.GA13514@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Cryptodev-linux-devel@gna.org
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20101019134418.GA13514@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 19, 2010 at 3:44 PM, Herbert Xu
<herbert@gondor.hengli.com.au> wrote:
> OK I've gone ahead and implemented the user-space API for hashes
> and ciphers.
> To recap this interface is designed to allow user-space programs
> to access hardware cryptographic accelerators that we have added
> to the kernel.
> The intended usage scenario is where a large amount of data needs
> to be processed where the benefits offered by hardware acceleration
> that is normally unavailable in user-space (as opposed to ones
> such as the Intel AES instruction which may be used directly from
> user-space) outweigh the overhead of going through the kernel.

What is the overall advantage of this API comparing to other existing
ones that achieve similar goals[0][1]?

Some observations:
1. To perform an encryption of data 6 system calls are made (I don't
count the 2 used for socket initialization since I suppose can be global
for all operations) and a file descriptor is assigned. The number of
system calls
made has great impact to the actual speed seen by userspace (as you said this
API is for user-space to access the high-speed peripherals that do encryption).
2. Due to the usage of read() and write() no zero-copy can happen for
user-space buffers[3].

regards,
Nikos

[0]. http://home.gna.org/cryptodev-linux/
[1]. http://home.gna.org/cryptodev-linux/ncr.html
[2]. The openbsd[0] api can do it with 3 system calls and NCR[1] with one,
and both require no file descriptor for each operation.
[3]. The openbsd[0] api and NCR[1] do zero-copy for user-space buffers.
