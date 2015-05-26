From: Stephan Mueller <smueller@chronox.de>
Subject: Re: [PATCH 5/7] esp6: Switch to new AEAD interface
Date: Tue, 26 May 2015 09:37:09 +0200
Message-ID: <1712288.Rcrx4S4ED0@tauon>
References: <20150521103938.GA23035@gondor.apana.org.au> <2306681.gksi6E3i3N@tachyon.chronox.de> <20150526072152.GA6407@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.eperm.de ([89.247.134.16]:58282 "EHLO mail.eperm.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751572AbbEZHhY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 May 2015 03:37:24 -0400
In-Reply-To: <20150526072152.GA6407@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Dienstag, 26. Mai 2015, 15:21:52 schrieb Herbert Xu:

Hi Herbert,

>On Tue, May 26, 2015 at 08:39:56AM +0200, Stephan Mueller wrote:
>> May I also ask where I can find the generated IV when using
>> rfc4106(gcm(aes))?
>You need to use the IV generator, seqniv(rfc4106(gcm(aes)))

Thank you, that simple change does the trick.

However, now, may I ask you how the following shall be handled:

- the current IKE implementations use rfc4106(gcm(aes)). They would need to 
use seqniv(rfc4106(gcm(aes))) depending on the kernel version. So, we have a 
clear change in the user space API where the old configuration even works 
(i.e. no error), but does not produce the correct encryption that is required.

- For outbound encryption of IPSEC, we need seqniv() as the IV needs to be 
generated. But for inbound, we do not need seqniv() as the IV is already given 
(before the patch, only esp_output used the givcrypt API whereas esp_input 
used the "normal" AEAD API). I would be interested on how that difference is 
to be handled.

Ciao
Stephan
