From: "Xiaoliang (David) Wei" <weixl@cs.caltech.edu>
Subject: The "retrans_out leaked."
Date: Sat, 19 Oct 2002 21:28:48 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <002301c277f1$2f6afe80$f5f2010a@weixl>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Everyone,
     I tried to change tcp with a tentative congestion control algorithm.
But sometimes, I got "retrans_out leaked." message, followed by series of
"KERNEL: assertion ((int)tcp_packets_in_flight(tp) >= 0) failed at
tcp_input.c" (generated at the end of tcp_sacktag_write_queue, where there
are serveral assertions:
#if FASTRETRANS_DEBUG > 0
 BUG_TRAP((int)tp->sacked_out >= 0);
 BUG_TRAP((int)tp->lost_out >= 0);
 BUG_TRAP((int)tp->retrans_out >= 0);
 BUG_TRAP((int)tcp_packets_in_flight(tp) >= 0);
#endif )

     Then, after a long list of such assertion failure, the kernel crashed
with some message saying intterupt handler error....

     Can anyone tell me what's the possible problems? Also, how inaccurate
is the packets_in_flight() calculation? Can it be negative?
     Thank you very much.

Xiaoliang (David) Wei             Graduate Student in CS@Caltech
http://www.cs.caltech.edu/~weixl
====================================================
