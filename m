From: "David S. Miller" <davem@redhat.com>
Subject: Re: Missing routes cause BUG() in icmpv6_xmit_lock().
Date: Sun, 31 Aug 2003 22:44:54 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030831224454.349a6a53.davem@redhat.com>
References: <1062341789.2785.11.camel@imladris.demon.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Woodhouse <dwmw2@redhat.com>
In-Reply-To: <1062341789.2785.11.camel@imladris.demon.co.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 31 Aug 2003 15:56:29 +0100
David Woodhouse <dwmw2@redhat.com> wrote:

> Attempt to ping6 the router 2002:X:Y::1 from internal host.
> Observe panic: http://www.linux.org.uk/~dwmw2/dcp_1575.jpg

The per-cpu ICMP6 socket locking is optimized assuming that
we'll never reenter the ICMP6 packet sending code on the
same processor, this link failure path is causing that to
happen.

Good thing the BUG() is there, else you'd get a lockup in this case
instead which would take us longer to hunt down :-)

I'll see what I can do about this one.
