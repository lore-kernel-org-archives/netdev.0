From: Stephan Mueller <smueller@chronox.de>
Subject: Re: [RFC PATCH 2/2] Crypto kernel tls socket
Date: Tue, 24 Nov 2015 12:00:06 +0100
Message-ID: <9662204.R2y95MbYda@tauon.atsec.com>
References: <cover.1448299690.git.davejwatson@fb.com> <ac7783121ef9442741d67aca5d170f02d851ae03.1448299690.git.davejwatson@fb.com> <20151124103455.GB623@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Tom Herbert <tom@herbertland.com>, netdev@vger.kernel.org,
	davem@davemloft.net,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.eperm.de ([89.247.134.16]:34558 "EHLO mail.eperm.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753009AbbKXLAN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Nov 2015 06:00:13 -0500
In-Reply-To: <20151124103455.GB623@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Dienstag, 24. November 2015, 18:34:55 schrieb Herbert Xu:

Hi Herbert,

>On Mon, Nov 23, 2015 at 09:43:02AM -0800, Dave Watson wrote:
>> Userspace crypto interface for TLS.  Currently supports gcm(aes) 128bit
>> only, however the interface is the same as the rest of the SOCK_ALG
>> interface, so it should be possible to add more without any user interface
>> changes.
>
>SOCK_ALG exists to export crypto algorithms to user-space.  So if
>we decided to support TLS as an algorithm then I guess this makes
>sense.
>
>However, I must say that it wouldn't have been my first pick.  I'd
>imagine a TLS socket to look more like a TCP socket, or perhaps a
>KCM socket as proposed by Tom.

If I may ask: what is the benefit of having TLS in kernel space? I do not see 
any reason why higher-level protocols should be in the kernel as they do not 
relate to accessing hardware.

The only reason I could fathom is to keep the negotiated keys in a secure 
realm. But that could be done without having parts or the whole TLS protocol 
stack in the kernel. If the key management should stay in the kernel as a 
protection domain, I would rather think that the kernel should offer a plug-
and-play of raw ciphers where user space is responsible to form a protocol. 
This way, we do not limit such key management to TLS, but allow any kind of 
protocol to use it.

E.g. the kernel performs the key transport with RSA or key agreement with DH 
using keyring-based key material. The resulting shared secret is again 
maintained in the key ring where user space can use the symmetric ciphers of 
the kernel with those keys. User space would only see references to keys but 
no real keys. However, only user space knows when to invoke what cipher to 
implement a specific protocol.

Ciao
Stephan
