From: Andrew Morton <akpm@digeo.com>
Subject: Re: Info: NAPI performance at "low" loads
Date: Tue, 17 Sep 2002 14:45:08 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D87A264.8D5F3AD2@digeo.com>
References: <3D879F59.6BDF9443@digeo.com> <20020917.142635.114214508.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: manfred@colorfullife.com, "netdev@oss.sgi.com" <netdev@oss.sgi.com>,
   linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

"David S. Miller" wrote:
> 
>    From: Andrew Morton <akpm@digeo.com>
>    Date: Tue, 17 Sep 2002 14:32:09 -0700
> 
>    There is a similar background loadtester at
>    http://www.zip.com.au/~akpm/linux/#zc .
> 
>    It's fairly fancy - I wrote it for measuring networking
>    efficiency.  It doesn't seem to have any PCisms....
> 
> Thanks I'll check it out, but meanwhile I hacked up sparc
> specific assembler for manfred's code :-)
> 
>    (I measured similar regression using an ancient NAPIfied
>    3c59x a long time ago).
> 
> Well, it is due to the same problems manfred saw initially,
> namely just a crappy or buggy NAPI driver implementation. :-)

It was due to additional inl()'s and outl()'s in the driver fastpath.

Testcase was netperf Tx and Rx.  Just TCP over 100bT. AFAIK, this overhead
is intrinsic to NAPI.  Not to say that its costs outweigh its benefits,
but it's just there.

If someone wants to point me at all the bits and pieces to get a
NAPIfied 3c59x working on 2.5.current I'll retest, and generate
some instruction-level oprofiles.
