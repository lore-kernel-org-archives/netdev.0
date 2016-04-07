From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 2/9] rxrpc: Disable a debugging statement that has been left enabled.
Date: Thu, 07 Apr 2016 22:24:53 +0100
Message-ID: <8082.1460064293@warthog.procyon.org.uk>
References: <20160407.165021.1271761992369838408.davem@davemloft.net> <1460046677.6715.95.camel@perches.com> <1091.1460058308@warthog.procyon.org.uk> <5702.1460062039@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: dhowells@redhat.com, joe@perches.com,
	linux-afs@lists.infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160407.165021.1271761992369838408.davem@davemloft.net>
Content-ID: <8081.1460064293.1@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:

> As you can with the function tracer and tracepoints.

I've had experience with tracepoints before (i2c and smbus).  It wasn't
particularly fun.  There's got to be some easier way to write them.

Hmmm...

Of the _enter() and _leave() macros in my tree at the moment, I have 261 that
record more information than just the name of the function.  I presume each
would need to be converted to a TRACE_EVENT*() macro as, as far as I can see
with a cursory examination, the function tracer doesn't record arguments or the
things arguments point to (which I do a lot of).  There are also another 84 of
these macros that only record the name of the function which are simpler
propositions.

Add to that 286 _debug(), _net() and _proto() macros, all of which record more
information than just the name of the calling function and don't have anything
particularly to do with function trace.

Now, I have been considering that the _net() and _proto() macros would probably
work well as TRACE_EVENT()-type constructs, allowing the tracing of protocol
flow.

I don't suppose you have a script for automatically converting something like
a printk()-type thing into a TRACE_EVENT()?

David
