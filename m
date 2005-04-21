From: Rick Jones <rick.jones2@hp.com>
Subject: is UDP_CORK "real"
Date: Thu, 21 Apr 2005 16:14:56 -0700
Message-ID: <426833F0.9010803@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I've been messing about with the latest netperf, and by accident specified -D 
for TCP_NODELAY on a UDP_RR test.  In the past, and even today on HP-UX at 
least, that results in an error on the setsockopt().  However, with the 
getaddrinfo() changes to netperf and the addtion of SCTP support, setsockopt() 
is now called with the ai_protocol from the getaddrinfo() call rather than a 
hard-coded IPPROTO_TCP.  Sooo, for UDP tests that becomes an IPPROTO_UDP.

When I run the UDP_RR test with -D set on a 2.6 kernel, netperf stops cold until 
the test timer expires.

It seems there is an overlap in the setsockopt() option numbers between TCP and 
UDP under Linux 2.6 at least, I've not gone back to check 2.4.  TCP_NODELAY and 
UDP_CORK are both defined as "1".  Those seem to be the only two options that 
overlap.  The other UDP_mumble option is defined to be 100, which is presently 
outside the range of the TCP_mumble options.  So, instead of trying to set 
TCP_NODELAY on a UDP socket, which would fail; netperf was unwittingly setting 
UDP_CORK on a UDP socket, which would succede.

Is UDP_CORK going to be an ongoing feature?  Is it a "real" feature today? While 
man tcp described TCP_CORK, on the two places I've checked thusfar, man udp does 
not describe UDP_CORK.  I'm not sure if that means UDP_CORK is "unreal" or just 
that the udp manpage needs repair (or was out of date on my systems).

I _can_ go in and have netperf check for IPPROTO_TCP and/or IPPROTO_SCTP before 
making the _NODELAY setsockopt, and I suppose I probably should, but if UDP_CORK 
isn't going to be around, or if TCP and UDP socket options were not _really_ 
meant to overlap... although the level option would seem to be there to allow it...

thanks,

rick jones
