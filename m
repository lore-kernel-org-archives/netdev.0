From: Phil Sutter <phil@nwl.cc>
Subject: Re: [RFC PATCH 2/2] Crypto kernel tls socket
Date: Tue, 24 Nov 2015 12:54:07 +0100
Message-ID: <20151124115407.GB23115@orbit.nwl.cc>
References: <cover.1448299690.git.davejwatson@fb.com>
 <ac7783121ef9442741d67aca5d170f02d851ae03.1448299690.git.davejwatson@fb.com>
 <20151124103455.GB623@gondor.apana.org.au>
 <9662204.R2y95MbYda@tauon.atsec.com>
 <871tbfhcf3.fsf@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephan Mueller <smueller@chronox.de>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Tom Herbert <tom@herbertland.com>, netdev@vger.kernel.org,
	davem@davemloft.net,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <871tbfhcf3.fsf@stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Tue, Nov 24, 2015 at 12:20:00PM +0100, Hannes Frederic Sowa wrote:
> Stephan Mueller <smueller@chronox.de> writes:
> 
> > Am Dienstag, 24. November 2015, 18:34:55 schrieb Herbert Xu:
> >
> > Hi Herbert,
> >
> >>On Mon, Nov 23, 2015 at 09:43:02AM -0800, Dave Watson wrote:
> >>> Userspace crypto interface for TLS.  Currently supports gcm(aes) 128bit
> >>> only, however the interface is the same as the rest of the SOCK_ALG
> >>> interface, so it should be possible to add more without any user interface
> >>> changes.
> >>
> >>SOCK_ALG exists to export crypto algorithms to user-space.  So if
> >>we decided to support TLS as an algorithm then I guess this makes
> >>sense.
> >>
> >>However, I must say that it wouldn't have been my first pick.  I'd
> >>imagine a TLS socket to look more like a TCP socket, or perhaps a
> >>KCM socket as proposed by Tom.
> >
> > If I may ask: what is the benefit of having TLS in kernel space? I do not see 
> > any reason why higher-level protocols should be in the kernel as they do not 
> > relate to accessing hardware.
> 
> There are some crypto acclerators out there so that putting tls into the
> kernel would give a net benefit, because otherwise user space has to
> copy data into the kernel for device access and back to user space until
> it can finally be send out on the wire.
> 
> Since processors provide aesni and other crypto extensions as part of
> their instruction set architecture, this, of course, does not make sense
> any more.

There "still" are dedicated crypto engines out there which need a driver
to be accessed, so using them from userspace is not as simple as with
padlock or AESNI. This was the reasoning behind the various cryptodev
implementations and af_alg. Using those to establish a TLS connection
with OpenSSL means to fetch encrypted data to userspace first and then
feed it to the kernel again for decryption. Using cryptodev-linux, this
will be zero-copy, but still there's an additional context switch
involved which the approach here avoids.

Cheers, Phil
