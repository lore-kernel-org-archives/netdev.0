From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: Linux support for RDMA (was: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed Topics)
Date: Mon, 4 Apr 2005 13:11:01 -0600
Message-ID: <20050404191101.GB6809@colo.lackof.org>
References: <67D69596DDF0C2448DB0F0547D0F947E01781F2E@yogi.asicdesigners.com> <1112576171.4227.5.camel@mylaptop> <20050404063456.GB30855@colo.lackof.org> <1112633650.9559.142.camel@beastie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "open-iscsi@googlegroups.com" <open-iscsi@googlegroups.com>,
        "David S. Miller" <davem@davemloft.net>, mpm@selenic.com,
        andrea@suse.de, michaelc@cs.wisc.edu,
        James.Bottomley@HansenPartnership.com, ksummit-2005-discuss@thunk.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Dmitry Yusupov <dmitry_yus@yahoo.com>
Content-Disposition: inline
In-Reply-To: <1112633650.9559.142.camel@beastie>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Apr 04, 2005 at 09:54:10AM -0700, Dmitry Yusupov wrote:
> > 	3) store back into RAM
> 
> no. we are talking about receive side optimization only.
> why do you think store back into RAM comes to the picture?

Application eventually wants to read the data.

> also keep in mind that we have huge L2 & L3 caches today and write
> operation is usually very well buffered.

Agreed. But how effective the cache is will depend on if the CPU
(application) can process the data as fast as it arrives (and still
be in the cache). Otherwise the data will get pushed out in (3)
and recalled later when the app can consume it (4th time across).

It also assumes the application is running on a CPU core that shares
the cache with the CPU that did the copy. If the CPU is saturated
with the copy (ok, assume we've got 2 Cores per socket), then the
other CPU has to be *assigned* manually to make sure it does the
other part.

Jamal learned all this when he moved to a dual core PPC for
his fast routing work. Jamal, did that ever make it into
a paper?

grant
