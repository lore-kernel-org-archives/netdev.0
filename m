From: Mark Smith <markzzzsmith@ozemail.com.au>
Subject: Re: [2.4.20] Frustrating DNS / UDP Socket flakeyness
Date: 22 Apr 2003 12:05:07 +0930
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1050978909.1755.2.camel@dupy>
References: <17626.1050885203@ocs3.intra.ocs.com.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Keith Owens <kaos@ocs.com.au>
In-Reply-To: <17626.1050885203@ocs3.intra.ocs.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Keith, 

Thanks for that, I'll give it a try. 

I've never come across this option before, and after all the years of
using dialup links with 1. and 2. series kernels, have never had this
problem before. It seemed to be a 2.4 series problem. 

It also was strange that it only appeared to happen when the link was
full of incoming TCP traffic. It was as though the TCP traffic was some
how getting priority over the UDP traffic in the incoming queue, which
then cause the socket timeout. 

It has just occurred to me that maybe my ISP is prioritising incoming
TCP traffic over UDP, which is why I only have this problem when
performing incoming (and maybe outgoing) TCP transfers. 

I'll see how I go.

Thanks, 
Mark. 

On Mon, 2003-04-21 at 10:03, Keith Owens wrote: 
> On 21 Apr 2003 02:05:32 +0930, 
> Mark Smith <markzzzsmith@ozemail.com.au> wrote:
> >While a TCP download is running, the UDP / DNS queries are sent, a
> >response comes back from the DNS server, but for some reason, in the
> >kernel appears to have closed the UDP socket, and therefore generates an
> >ICMP destination unreachable, port unreachable message back to the DNS
> >server.
> 
> The response takes too long so the resolver is timing out the request
> and trying another server.  When the delayed response arrives, the
> resolver has closed the socket so the icmp reject is correct.  The
> default timeout is 5 seconds, try adding 'options timeout:10' to
> /etc/resolv.conf.
> 
> 
