From: "Michael Kerrisk" <michael.kerrisk@gmx.net>
Subject: TCP_CORK 200ms maximum cork time -- expected behaviour?
Date: Thu, 01 Jul 2004 14:47:13 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40E423F1.31890.6CC4104@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: michael.kerrisk@gmx.net
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-description: Mail message body
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Gidday,

The TCP_CORK socket option allows us to perform 
multiple write()s (or send()s or sendfile()s) 
while delaying the transmission of an outgoing 
TCP segment until the option is disabled (or a 
segment MSS is filled or the socket is closed).

All is fine and good, but there's one point I'm 
puzzled about: even when TCP_CORK is set, 
buffered data will still be transmitted 
after a 200 millisecond delay (the delay 
counts from the time that the first corked byte 
was written), even if TCP_CORK is still set.  
So, I'm wondering:

1. Is this intended behaviour, or simply an 
   outgrowth of the combined implementations of 
   TCP_CORK and TCP_NAGLE_OFF?

2. If it's intended behaviour, what is the 
   rationale for the ceiling time on corking?

Cheers,

Michael

PS I first observed this behaviour quite some time 
back, but I've verified that it is still current 
(2.4.26 and 2.6.7 kernels).  (In passing: of 
course, similar behaviour occurs with MSG_MORE on 
TCP sockets.)
