From: Stephan Mueller <smueller@chronox.de>
Subject: Re: [PATCH 5/7] esp6: Switch to new AEAD interface
Date: Tue, 26 May 2015 09:56:17 +0200
Message-ID: <2094137.hWyJz1gPAp@tauon>
References: <20150521103938.GA23035@gondor.apana.org.au> <1712288.Rcrx4S4ED0@tauon> <20150526073858.GA6634@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20150526073858.GA6634@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Dienstag, 26. Mai 2015, 15:38:59 schrieb Herbert Xu:

Hi Herbert,

>On Tue, May 26, 2015 at 09:37:09AM +0200, Stephan Mueller wrote:
>> - the current IKE implementations use rfc4106(gcm(aes)). They would need to
>> use seqniv(rfc4106(gcm(aes))) depending on the kernel version. So, we have
>> a
>> clear change in the user space API where the old configuration even works
>> (i.e. no error), but does not produce the correct encryption that is
>> required.
>You mean through the user-space AEAD interface? That's not a problem
>because I'm going to disable it for 4.1 :)

Actually, I mean the real in-kernel crypto API: the IKE daemon would set up 
the SA via XFRM where the rfc4106(gcm(aes)) cipher is set, is it not? So, user 
space is responsible to set the right IPSEC cipher.

As that user space cipher name is now changed, user space would need to be 
aware of that modification, would it not?

PS: I just tried seqniv(rfc4106(gcm(aes))) via AF_ALG and it works without 
crashing the kernel. I have not yet checked whether the data returned by 
recvmsg is cryptographically sound.

Ciao
Stephan
