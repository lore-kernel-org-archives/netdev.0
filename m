From: Jeremy Kerr <jeremy@redfishsoftware.com.au>
Subject: Reenabling TSO
Date: Mon, 8 Mar 2004 15:32:02 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200403081532.02830.jeremy@redfishsoftware.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: anton@au.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi all,

I've been running a few tests on the TSO & e1000 code which involve stressing 
a link between two hosts. The test program is rather trivial, simply repeated 
calls to sendfile() over a socket. The problem occurs when we see a TCP 
retransmit on the connection, after which TSO is disabled.

After looking through tcp_{input,output}.c, there seems to be no code to 
reenable TSO - so one retransmit will permanently disable TSO for a socket. 
This isn't such a problem for short-lived connections, but longer-lived ones 
will only use TSO for a small proportion of the data transferred, depending 
on the frequency of retransmits.

So, two questions:

Is it practical to reenable TSO at all? 

and

What metric do we use to determine when it is safe to reenable TSO? A simple 
metric may be the TCP window size - when this reaches a predefined threshold, 
we can set the  flag again. However, something more complex involving the 
number of sent packets and number of retransmits may be required.

Any thoughts?


Jeremy
