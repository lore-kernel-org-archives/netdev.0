From: Nikos Mavrogiannopoulos <nmav@gnutls.org>
Subject: Re: [PATCH 0/3] crypto: af_alg - add TLS type encryption
Date: Thu, 14 Apr 2016 08:47:54 +0200
Message-ID: <CAJU7zaJ434afnPTEGUvZOPbAyMnUDjLKP1xUyLVcyTZ5Hesq4Q@mail.gmail.com>
References: <20160306012044.6369.63924.stgit@tstruk-mobl1> <20160405112940.GB11852@gondor.apana.org.au>
 <57054DBC.8010507@intel.com> <20160408025250.GA7596@gondor.apana.org.au>
 <CALx6S37m_ayZJ4nth0SPNr2Km2+uBZUCtK4iqPKHTARv2eB4aA@mail.gmail.com>
 <570CD852.7060003@redhat.com> <570ECC28.3030008@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Fridolin Pokorny <fpokorny@redhat.com>,
	Tom Herbert <tom@herbertland.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Dave Watson <davejwatson@fb.com>, fridolin.pokorny@gmail.com
To: Tadeusz Struk <tadeusz.struk@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <570ECC28.3030008@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 14, 2016 at 12:46 AM, Tadeusz Struk <tadeusz.struk@intel.com> wrote:
> Hi Fridolin,
> On 04/12/2016 04:13 AM, Fridolin Pokorny wrote:
>> we were experimenting with this. We have a prove of concept of a kernel
>> TLS type socket, so called AF_KTLS, which is based on Dave Watson's
>> RFC5288 patch. It handles both TLS and DTLS, unfortunately it is not
>> ready now to be proposed here. There are still issues which should be
>> solved (but mostly user space API design) [1]. If you are interested, we
>> could combine efforts.
>>
>> Regards,
>> Fridolin Pokorny
>>
>> [1] https://github.com/fridex/af_ktls
> I had a quick look and it looks like is limited only to gcm(aes).
> I would be more interested to have a generic interface that could do generic algorithm
> suits like aes-cbc-hmac-sha1 also.

This is not a real limitation but an advantage. The cbc-hmac-sha1
needs a lot of hacks to be implemented correct (just take a look at
one of the existing implementations). There is no point to bring such
hacks into kernel especially since these ciphersuites are banned from
HTTP/2.0 (see RFC7540), and have been dropped from TLS 1.3.

> This also seems to work in a synchronous (send one and wait) mode, which is a not good
> solution for HW accelerators, which I'm trying to enable.

Is that something that cannot be addressed?

regards,
Nikos
