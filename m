From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC][PATCH 2/2] ip multipath, bk head (EXPERIMENTAL)
Date: 13 Sep 2004 22:40:24 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095129624.1060.45.camel@jzny.localdomain>
References: <41457848.6040808@de.ibm.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: lkml@einar-lueck.de
In-Reply-To: <41457848.6040808@de.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-09-13 at 06:36, Einar Lueck wrote:
[..]
> The basic idea of the proposed patch is to utilize a new flag at the
> "struct dst_entry" flags field to indicate that further routes having 
> the same key follow in the routing cache chain. Consequently, at cache lookup time
> we recognize this flag and may apply different load balancing policies 
> to the available routes having the same key. The Garbage Collection is modified in
> a way that ensures that all routes having the same target  are removed
> together from the cache.

As long as whatever arrangement ensures that no packet reordering
happens, should be sane. Yes, current scheme is broken in some ways (but
guarantees packet ordering within a flow).
Clearly the better way is to have all N equal path routes in an array of
size N somehow also attached to the hash chain. Then policy flag selects
algorithm executed to select 1 of N. The real difference between all of
them is what the nexhop is (oif and NH MAC and maybe src IP if local).

My opinion: we should kill the current code altogether and do this as
post routing decision to make it more flexible. I have a tc action i am
working on that could have a preprocessor of an action like a policer
"flow X has now exceeded 10Mbps we need to select new route". Of course
there could be a lot of other state used in overruling routing
decisions; eg attached contracking information could be useful etc.
There are a few challeneges to make this reality (other than the ReMAC
action i am working on).

cheers,
jamal
