From: Praveen Kumar Amritaluru <praveen@india.hp.com>
Subject: zero window probes on linux (fwd)
Date: Tue, 13 Apr 2004 15:43:29 +0530 (IST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200404131013.PAA18883@shilpa.india.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: praveen@shilpa.india.hp.com (Praveen Kumar Amritaluru)
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

	I am running a  client-server  program with client  running on a
	linux machine with 2.4.18-14 kernel installed.

	When the server  announces  zero-window  to the  client,  client
	starts  sending   zero-window   probes  which  are  nothing  but
	unacceptable segments.

	A short trace  obtained  using  tcpdump  and  interpreted  using
	ethereal is shown below:


16:27:17.979349 e.f.g.h.33464 > a.b.c.d.40000: P Seq=76441951 Ack=802335667 Win 5840 len=1080
16:27:18.040407 a.b.c.d.40000 > e.f.g.h.33464: . Seq=802335667 Ack=764413031 Win 0 len=0
16:27:18.256213 e.f.g.h.33464 > a.b.c.d.40000: . Seq=764413030 Ack=802335667 Win 5840 len=0

	This sequence  continues as per  retransmission  algorithm  with
	same seq no.  and ack no on both ends of TCP connection.

	It can be seen above that unacceptable  zero-length packets with
	a  sequence  no.  already   unacknowledged   is  being  used  as
	zero-window probes.

	Zero  window  probes are defined in RFC 793 and  RFC1122 to be a
	data  segment  containing  atleast  one byte of data  beyond the
	window of the receiver who has closed the window.

	This  seems  to be a bug.  Has it been  already  fixed in  later
	kernel versions or is this how it is intended to remain?


Regards,

Praveen
