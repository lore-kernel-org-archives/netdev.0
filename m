From: Mike Stroyan <mike.stroyan@hp.com>
Subject: Re: send(), sendmsg(), sendto() not thread-safe
Date: Tue, 16 May 2006 10:24:46 -0600
Message-ID: <20060516162446.GA26068@ldl.lart>
References: <4469201F.4030207@hp.com> <OF4D94549F.7BBB070C-ON85257170.0009219D-88257170.000A05E8@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rick Jones <rick.jones2@hp.com>,
	Linux Network Development list <netdev@vger.kernel.org>,
	shemminger@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:3755 "EHLO atlrel7.hp.com")
	by vger.kernel.org with ESMTP id S1751850AbWEPQYw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 May 2006 12:24:52 -0400
To: Mark A Smith <mark1smi@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <OF4D94549F.7BBB070C-ON85257170.0009219D-88257170.000A05E8@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 15, 2006 at 06:50:36PM -0700, Mark A Smith wrote:
> 
> I cannot think of another possible definition for thread-safe in the
> context of these functions. Certainly they should not cause a "crash" when
> called from multiple threads, but that's a requirement independent of
> thread-safety.
...
> I think the question really boils down to: "What does thread-safe mean with
> respect to send()?" It might be more easily answered by asking, "How would
> a non-thread-safe send() behave?" I think it would behave the way we're
> seeing it behave.

  A non-thread-safe send() could use a global buffer to hold copied
data or results.  When called from multiple threads it could lose data
or mix data from send()s to different sockets.  Or it could return a
result in one thread that reflects the result of an overlapping send()
in another thread.  Or it could sometimes core dump.  The behavior of
a non-thread-safe function called from multiple threads is undefined.
There is really no requirement "independent of thread-safety" on the
behavior of a function called from multiple unsyncronized threads.

  As Rick noted, this is not really a threading test but a multiprocess
test.  A requirement to be thread-safe shouldn't imply anything about
the behavior of functions in single-threaded processes.  The posix
standard has a limit of PIPE_BUF bytes for atomic writes to a pipe.
That might extend to expecting sends of under PIPE_BUF bytes to be atomic
on a socket.  But I don't actually find any guarantee of atomic writes
for sockets, even for sizes below PIPE_BUF.

-- 
Mike Stroyan, mike.stroyan@hp.com
