From: "David S. Miller" <davem@redhat.com>
Subject: Re: dev->destructor
Date: Thu, 01 May 2003 04:09:35 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030501.040935.68070653.davem@redhat.com>
References: <20030501.000058.39187964.davem@redhat.com>
	<20030501120815.25BE22C155@lists.samba.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, shemminger@osdl.org, netdev@oss.sgi.com,
   acme@conectiva.com.br, wa@almesberger.net
Return-path: <netdev-bounce@oss.sgi.com>
To: rusty@rustcorp.com.au
In-Reply-To: <20030501120815.25BE22C155@lists.samba.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Rusty Russell <rusty@rustcorp.com.au>
   Date: Thu, 01 May 2003 22:01:19 +1000
   
   There are 70 calls to dev_hold() in the kernel.  The vast majority of
   them already have a reference, they just want another one: dev_hold()
   can do __module_get().

Rusty, this is precisely the what Alexey and myself want to avoid.  On
the surface, it looks fine, only 70 dev_get's in the kernel right?
But think further...

So you propose to add this kind of thing for every ARP entry, every
route cache entry, every IPSEC policy, every socket, every struct
sock, every networking dynamic object ever created?

When we add SKB recycling, will we need to do a module get/put on
every SKB alloc/free/clone/copy?

I think this way lies insanity :) You may make the decision to eat
this kind of overhead inside of netfilter, but Alexey and I do not
accept this.  I disagreed with Alexey initially, but now I truly see
his wisdom.

This networking device example is just the tip of the iceberg.  We can
continue to add bandaids across the kernel, instead of solving the
real problem that modules need to manage their own removal.

It is at the core of the reason the current module scheme has to be
extended to let the module manage unloading.
