From: Ralph Doncaster <ralph@istop.com>
Subject: Re: route-cache performance
Date: Tue, 26 Aug 2003 23:02:22 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.51.0308262255110.6892@ns.istop.com>
References: <Pine.LNX.4.51.0308252328140.26713@ns.istop.com>
Reply-To: ralph+d@istop.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: "netdev@oss.sgi.com" <netdev@oss.sgi.com>
In-Reply-To: <Pine.LNX.4.51.0308252328140.26713@ns.istop.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

With my latest testing I'm having problems getting Linux to go under full
load generating packets with juno.  With just sending I was able to get
330kpps and 0% idle with just one juno thread.

I setup a test for routing performance with a routing loop between 2
identical boxes; one running FreeBSD 5.0 and the other running Linux
2.4.22rc2.  On my first attempt I forgot to enable polling on the BSD box
and caused livelock.  On my second attempt (polling enabled) the Linux box
was still at 52% idle, even with 4 juno threads.  The BSD box was showing
49% idle.  The the aggregate throughput of the 4 juno threads was just
92kpps.  The linux box was running zebra with full BGP routes (same setup
as the test I posted about yesterday).

Here's the profile details:

   136 raw_getrawfrag                             0.6071
    73 kfree_skbmem                               0.6518
   150 skb_release_data                           0.9375
    48 kmem_cache_free                            1.0000
   121 __generic_copy_from_user                   1.0804
   198 eth_type_trans                             1.1250
    86 system_call                                1.5357
   177 handle_IRQ_event                           1.5804
   175 kfree                                      2.7344
  4455 default_idle                              69.6094

What changes can I make to max out the Linux box?

Ralph Doncaster, IStop.com president
6042147 Canada Inc.
