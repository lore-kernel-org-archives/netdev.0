From: Keith Owens <kaos@ocs.com.au>
Subject: Re: [2.4.20] Frustrating DNS / UDP Socket flakeyness
Date: Mon, 21 Apr 2003 10:33:23 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <17626.1050885203@ocs3.intra.ocs.com.au>
References: <1050856532.1816.22.camel@dupy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mark Smith <markzzzsmith@ozemail.com.au>
In-reply-to: Your message of "21 Apr 2003 02:05:32 +0930."
             <1050856532.1816.22.camel@dupy>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 21 Apr 2003 02:05:32 +0930, 
Mark Smith <markzzzsmith@ozemail.com.au> wrote:
>While a TCP download is running, the UDP / DNS queries are sent, a
>response comes back from the DNS server, but for some reason, in the
>kernel appears to have closed the UDP socket, and therefore generates an
>ICMP destination unreachable, port unreachable message back to the DNS
>server.

The response takes too long so the resolver is timing out the request
and trying another server.  When the delayed response arrives, the
resolver has closed the socket so the icmp reject is correct.  The
default timeout is 5 seconds, try adding 'options timeout:10' to
/etc/resolv.conf.
