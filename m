From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Change MAC without bringing interface down
Date: Mon, 18 Aug 2003 05:12:27 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030818051227.4f35f2f3.davem@redhat.com>
References: <20030818091312.GA4889@lapdog>
	<20030818041911.358c3437.davem@redhat.com>
	<1061208824.16010.2119.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: tv@debian.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1061208824.16010.2119.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 18 Aug 2003 08:13:44 -0400
jamal <hadi@cyberus.ca> wrote:

> Editing the header may be the better approach if you have a few hundred 
> hhs already inserted (this was the issue i was faced with when VRRP was
> failing over when i was playing with it). I tried to flush the cache but
> it took longer to recover it. 

There is another reason I want the cache flushed.

Those hh cache entries are what ARP resolved to when we
had the previous MAC address, not the one we have now.

The ARPs may come back differently with the new MAC
address.

I _REALLY REALLY_ don't want to have to change the
->update() implementations.  Although one thing I
would consider is a new ->update_src() operation
and if this were NULL we flush the entries instead.
