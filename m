From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: Early SPECWeb99 results on 2.5.33 with TSO on e1000
Date: Fri,  6 Sep 2002 12:45:00 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1031341500.3d7905bce1a63@imap.linux.ibm.com>
References: <3D78E7A5.7050306@us.ibm.com> <20020906202646.A2185@wotan.suse.de> <1031339954.3d78ffb257d22@imap.linux.ibm.com> <20020906.122118.52140394.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: ak@suse.de, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20020906.122118.52140394.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Quoting "David S. Miller" <davem@redhat.com>:

> There are methods to eliminate the centrality of the
> port allocation locking.
> 
> Basically, kill tcp_portalloc_lock and make the port rover be
> per-cpu.

Aha! Exactly what I started to do quite a while ago..

> The only tricky case is the "out of ports" situation.  Because
> there is no centralized locking being used to serialize port
> allocation, it is difficult to be sure that the port space is truly
> exhausted.

I decided to use a stupid global flag to signal this..It did become
messy and I didnt finalize everything. Then my day job 
intervened :). Still hoping for spare time*5 to complete
this if none comes up with something before then..

> Another idea, which doesn't eliminate the tcp_portalloc_lock but
> has other good SMP properties, is to apply a "cpu salt" to the
> port rover value.  For example, shift the local cpu number into
> the upper parts of a 'u16', then 'xor' that with tcp_port_rover.

nice..any patch extant? :)

thanks,
Nivedita
