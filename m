From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: struct sock size limit?
Date: Sun, 27 Oct 2002 03:18:40 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021027061840.GA4720@conectiva.com.br>
References: <Pine.LNX.4.33L0.0210262236120.4401-100000@fast2.cs.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Cheng Jin <chengjin@cs.caltech.edu>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.33L0.0210262236120.4401-100000@fast2.cs.caltech.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Sat, Oct 26, 2002 at 10:44:03PM -0700, Cheng Jin escreveu:
> Hi,
> 
> I have been adding members to struct sock (by changing struct tcp_opt) in
> linux 2.4.18-3 kernel.  I haven't had problems with the kernel until
> today.   When I added a few more bytes (~ 20 bytes) on top of my old
> addition (around 80 bytes), the kernel would crash calling udp_sendmsg

beware the data dependencies of struct sock and tcp_tw_bucket, etc, I
bet you're adding new struct members at the start of struct sock, see the
comment in include/net/tcp.h, just above struct tcp_tw_bucket definition...
and also study current include/net/sock.h in 2.5, this thing was all
changed (for the better 8) ).

> (syslogd initialization).  I suspect that there may be some kind of size
> limit with struct sock/tcp_opt.  The TCP connected state is checked
> from within udp_sendmsg (no idea why that is so).

so look at other protocols such as decnet that also uses the TCP_ state
macros :-) its just reusing those macros.
 
> I searched around on google, but didn't find anything on struct sock or
> struct tcp_opt.  Does anyone know whether the size of struct sock/tcp_opt
> is capped?
> 
> Thanks a lot,
> 
> Cheng
> 
> Lab # 626 395 8820
> 
