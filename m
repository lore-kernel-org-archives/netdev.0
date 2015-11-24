From: Stephan Mueller <smueller@chronox.de>
Subject: Re: [RFC PATCH 2/2] Crypto kernel tls socket
Date: Tue, 24 Nov 2015 13:36:34 +0100
Message-ID: <3088087.5zdKq9bTtW@tauon.atsec.com>
References: <cover.1448299690.git.davejwatson@fb.com> <871tbfhcf3.fsf@stressinduktion.org> <20151124115407.GB23115@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Tom Herbert <tom@herbertland.com>, netdev@vger.kernel.org,
	davem@davemloft.net,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com
To: Phil Sutter <phil@nwl.cc>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20151124115407.GB23115@orbit.nwl.cc>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Dienstag, 24. November 2015, 12:54:07 schrieb Phil Sutter:

Hi Phil,
>
>There "still" are dedicated crypto engines out there which need a driver
>to be accessed, so using them from userspace is not as simple as with
>padlock or AESNI. This was the reasoning behind the various cryptodev
>implementations and af_alg. Using those to establish a TLS connection
>with OpenSSL means to fetch encrypted data to userspace first and then
>feed it to the kernel again for decryption. Using cryptodev-linux, this
>will be zero-copy, but still there's an additional context switch
>involved which the approach here avoids.

Well, when being nasty, I could ask, why not putting the entire web server 
into the kernel. Heck, why not getting rid of user space?

Sorry, I could not resist. :-)

But back to the technical discussion. My main concern is that TLS is a big 
protocol and it is by far not the only crypto protocol where all those 
protocols seem to uses the same crypto primitives. And to me, there should be 
a good reason why software executes in supervisor state. Simply saving some 
context switches is not a good argument, because the context switches are 
there for a reason: to keep the system safe and secure.

Ciao
Stephan
