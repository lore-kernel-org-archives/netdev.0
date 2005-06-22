From: Andi Kleen <ak@suse.de>
Subject: Re: RFC: NAPI packet weighting patch
Date: Wed, 22 Jun 2005 20:06:55 +0200
Message-ID: <20050622180654.GX14251@wotan.suse.de>
References: <1119458226.6918.142.camel@localhost.localdomain> <200506221801.j5MI11xS021866@guinness.s2io.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, "'Donald Becker'" <becker@scyld.com>,
        "'Andi Kleen'" <ak@suse.de>, "'Rick Jones'" <rick.jones2@hp.com>,
        netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Leonid Grossman <leonid.grossman@neterion.com>
Content-Disposition: inline
In-Reply-To: <200506221801.j5MI11xS021866@guinness.s2io.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Outside of the filters capability, from the (granted, pretty limited)
> testing we see some noticeable improvement from providing status bits but it
> is not as big as I would expect,
> It looks like the headers are still being touched somewhere... We will look
> at this some more.

The headers are read of course in the main stack. No way around that.

It basically helps you only when you can space the prefetch for the header
out long enough that the data is in cache when you need it. However
it is tricky because CPUs have only a limited load queue entries and doing
too many prefetches will just overflow that.

This can be done by batching L2 packet processing, but doing so 
is not good for your latency.

-Andi
