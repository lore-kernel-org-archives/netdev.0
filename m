From: "David S. Miller" <davem@redhat.com>
Subject: Re: sequence number problem with zero length window size
Date: Tue, 08 Apr 2003 15:17:05 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030408.151705.73784032.davem@redhat.com>
References: <16019.1179.697600.659029@eagle.skarven.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: lkml@winux.com
In-Reply-To: <16019.1179.697600.659029@eagle.skarven.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: lkml@winux.com
   Date: Tue, 8 Apr 2003 13:19:23 -0400

   This IS the problem I'm reporting:
   
     When the window size goes to zero, the sender (Linux 2.4.19) sends a
     packet with the wrong sequence number.  In the attached trace, see
     packets starting at number 5470, time stamp 695.453571. Here the
     client acks for sequence number ....741 but the sender then sends
     a packet with sequence number ...740.
   
Congratulations, you've witnessed a zero-window probe.

This is not a bug.  We probe zero windows by sending a dummy
byte "in the past" that we know the other side has received
already, because this packet will be:

1) legal, in the window

2) make the other side generate an ACK and thus give us
   an updated indication of the current window size
