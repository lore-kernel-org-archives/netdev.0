From: Stephan Mueller <smueller@chronox.de>
Subject: Re: [PATCH 5/7] esp6: Switch to new AEAD interface
Date: Tue, 26 May 2015 10:15:37 +0200
Message-ID: <2896909.aPhD1VIluo@tauon>
References: <20150521103938.GA23035@gondor.apana.org.au> <2094137.hWyJz1gPAp@tauon> <20150526075759.GA6849@gondor.apana.org.au>
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
Received: from mail.eperm.de ([89.247.134.16]:58322 "EHLO mail.eperm.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754135AbbEZONi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 May 2015 10:13:38 -0400
In-Reply-To: <20150526075759.GA6849@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Dienstag, 26. Mai 2015, 15:57:59 schrieb Herbert Xu:

Hi Herbert,

>On Tue, May 26, 2015 at 09:56:17AM +0200, Stephan Mueller wrote:
>> Actually, I mean the real in-kernel crypto API: the IKE daemon would set up
>> the SA via XFRM where the rfc4106(gcm(aes)) cipher is set, is it not? So,
>> user space is responsible to set the right IPSEC cipher.
>> 
>> As that user space cipher name is now changed, user space would need to be
>> aware of that modification, would it not?
>
>No the change was done in a backwards compatible way.  So if you
>allocate rfc4106(gcm(aes)) and use the givencrypt interface (not
>encrypt) then you still get the old behaviour.

I fully understand that. But the current patch set that we discuss modifies 
the IPSEC implementation of esp_ouput to use the new interface. Therefore, to 
use rfc4106(gcm(aes)) *with* the IV generator (i.e. to get the old removed 
givcrypt logic), the AEAD cipher handle must be allocated with 
seqniv(rfc4106(gcm(aes))), would it not?

Therfore, I would assume that user space has to use the new cipher name when 
setting up IPSEC that uses the new interface.

Ciao
Stephan
