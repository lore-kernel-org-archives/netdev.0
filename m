From: Andi Kleen <ak@suse.de>
Subject: Re: do_gettimeofday
Date: Thu, 2 Oct 2003 21:29:42 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031002192942.GB29673@wotan.suse.de>
References: <3F7C6F3B.6070502@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Steve Modica <modica@sgi.com>
Content-Disposition: inline
In-Reply-To: <3F7C6F3B.6070502@sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Oct 02, 2003 at 01:32:27PM -0500, Steve Modica wrote:
> We've been doing some experiments here with large numbers of adapters on a 
> 64p Linux system. 
> When running 8 threads and 8 cpus, the do_gettimeofday code starts to use a 
> lot of time.

That's a known problem. The funny thing is that the only users
of this time stamp is SO_TIMESTAMP, which is rarely used (except tcpdump)
and something in DECnet. IMHO the right fix is to add a global
counter that counts all all sockets that use SO_TIMESTAMP and when it's
zero never call it. Decnet could be probably fixed to just use jiffies
like TCP does.

Drawback is that when you enable SO_TIMESTAMP there is a small time window
when the packets are not time stamped yet. The socket layer can just fill
in the current time though.

-Andi
