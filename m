From: Cheng Jin <chengjin@cs.caltech.edu>
Subject: Re: Long-term TCP connections suffer on high-latency links.
Date: Thu, 29 Jul 2004 22:28:01 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0407292206490.9625-100000@fast2.cs.caltech.edu>
References: <4109D63E.5070006@candelatech.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <4109D63E.5070006@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ben,

> But, TCP has been around a long while, and surely other people
> have noticed things like this, so what am I missing?

There are a number of research groups working on addressing the inefficiencies
of the current TCP (NewReno) at large windows in both theory and 
experimental work.

The experimental work would probably be more interesting for this mailing 
list.  The protocols (that I know) that try to address this issue are:

Highspeed TCP: http://www.icir.org/floyd/hstcp.html
Scalable TCP: http://www-lce.eng.cam.ac.uk/~ctk21/scalable/
FAST TCP: http://netlab.caltech.edu/FAST
H-TCP: http://hamilton.ie/net/main.htm?index
BIC TCP/CUBIC: http://www.csc.ncsu.edu/faculty/rhee/export/bitcp/
a related project for finding performance bottlenecks in the network stack
is web100: http://www.web100.org

As of 2.6.6 kernel, TCP Westwood, which mainly addresses issues in 
wireless networks, BIC TCP, and TCP Vegas are all included besides TCP 
NewReno, although not enabled by default.  The others can be downloaded 
from the given websites.  There are probably others that I forgot to 
mention.  Apologies to them in advance.

Making the current TCP more ``efficient'' by increasing cwnd faster is not 
an adequate solution, although doing that will likely produce higher 
throughput in today's Internet.  We also must consider issues such as 
fairness to other flows, stability of the network in terms of queue
oscillation and packet loss, and how well these solutions would scale in 
future networks.  A lot of experiments are still needed to determine which 
is the most appropriate under what circumstances.

Cheng
