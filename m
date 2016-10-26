From: Phil Sutter <phil@nwl.cc>
Subject: Re: concurrent rhashtable test failure
Date: Wed, 26 Oct 2016 09:33:37 +0200
Message-ID: <20161026073337.GM5640@orbyte.nwl.cc>
References: <CAMuHMdWTqXaJAM-O+mmha=JbuyvvNxYyHuV6e4YK7oUkh9rCkA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        linux-m68k <linux-m68k@lists.linux-m68k.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:35684 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753369AbcJZHdj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Oct 2016 03:33:39 -0400
Content-Disposition: inline
In-Reply-To: <CAMuHMdWTqXaJAM-O+mmha=JbuyvvNxYyHuV6e4YK7oUkh9rCkA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Geert,

On Mon, Oct 24, 2016 at 02:11:32PM +0200, Geert Uytterhoeven wrote:
> On m68k/ARAnyM, test_rhashtable fails with:
> 
>     Test failed: thread 0 returned: -4
> 
> (-4 = -EINTR)

How reproducible is this? I wonder why out of the ten threads only the
first one fails.

> I traced this back to your commit f4a3e90ba5739cfd ("rhashtable-test: extend
> to test concurrency"), which added that part of the test.
> 
> Diff of the test output between the failing commit and its parent:
> 
>  Running rhashtable test nelem=8, max_size=65536, shrinking=0
>  Test 00:
>    Adding 50000 keys
>    Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
>    Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
>    Deleting 50000 keys
> -  Duration of test: 1029960000 ns
> +  Duration of test: 990000000 ns
>  Test 01:
>    Adding 50000 keys
>    Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
>    Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
>    Deleting 50000 keys
> -  Duration of test: 990000000 ns
> +  Duration of test: 720000000 ns
>  Test 02:
>    Adding 50000 keys
>    Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
>    Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
>    Deleting 50000 keys
> -  Duration of test: 1130000000 ns
> +  Duration of test: 700000000 ns
>  Test 03:
>    Adding 50000 keys
>    Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
>    Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
>    Deleting 50000 keys
> -  Duration of test: 1080000000 ns
> -Average test time: 1057490000
> +  Duration of test: 700000000 ns
> +Average test time: 777500000
> +Testing concurrent rhashtable access from 10 threads
> +Test failed: thread 0 returned: -4
> +Started 10 threads, 1 failed
> 
> Do you have any clue?

Not really, I merely implemented the test.

Thanks, Phil
