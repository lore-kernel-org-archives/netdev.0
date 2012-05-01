From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [REGRESSION][PATCH V4 3/3] bpf jit: Let the powerpc jit handle
 negative offsets
Date: Tue, 01 May 2012 10:26:27 +1000
Message-ID: <1335831987.20866.93.camel@pasglop>
References: <1335760199.20866.33.camel@pasglop>
	 <4F9E188E.80503@googlemail.com> <1335763568.20866.37.camel@pasglop>
	 <20120430.134140.1738751315208907289.davem@davemloft.net>
	 <1335822926.20866.47.camel@pasglop> <1335823049.20866.48.camel@pasglop>
	 <4F9F12ED.1090009@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jan Seiffert <kaffeemonster@googlemail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F9F12ED.1090009@googlemail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-05-01 at 00:32 +0200, Jan Seiffert wrote:

> *shudder*
> Link to another lib for only one function because....
> 
> http://cvsweb.netbsd.org/bsdweb.cgi/src/sys/net/bpf.h?rev=1.59&content-type=text/x-cvsweb-markup&only_with_tag=MAIN
> The "Original" says it's an u_int.
> 
> But i guess it is unfixable without breaking something, except with ugly code.
> Should the padding at least be made explicit in the in-kernel struct?
> Did anyone ever tested the 32bit on 64bit compat code (different padding)?

Haven't tested no. A quick google pointed to 2 web pages telling people
to do the wrong thing and 4 broken programs out there, interestingly in
different ways :-) (somebody's doing a reinterpret_cast of one struct
into another, somebody does his/her own local redefinition of the
struct ... using a ulong !, etc....)

I don't see a good way to sort that out other than introducing a new
kernel-side structure, change the sockopt number, and support the old
one as backward binary compat, but that's gross.

Cheers,
Ben.
