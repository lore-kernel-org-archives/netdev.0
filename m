From: "Joseph Conlin" <JCONLIN@novell.com>
Subject: Replace the Nagle Algorithm
Date: Mon, 20 Oct 2003 12:58:19 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <sf93dbf5.079@prv-mail20.provo.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <jrd@cc.usu.edu>
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I see in the archives and the code that I have looked at (2.4.22,
2.6.0-test8) that the Minshall algorithm is being used to reduce the
effects of Nagle/delayed ACK interaction.  I haven't seen any mention of
the following solution, proposed as an IETF draft RFC by Joe Doupnik
(jrd@cc.usu.edu).

http://netlab1.usu.edu/pub/misc/draft-doupnik-tcpimpl-nagle-mode-00.txt


I quote the following from the abstract.

A new TCP transmission policy is discussed in this memo which uses
  information known only to the transmitter about when to send
  segments. It groups octets based on filling segments and sending a
  small segment when the application indicates no more data are
  immediately available, not on arrival of ACKs. It works well with
and
  avoids deadlocks with delayed ACKs. It is automatic and does not
need
  to be turned off. It is a suitable replacement for Nagle mode.

I also point you to the following location, which shows the code
changes for FreeBSD 3.2, Linux 2.2.5-15, and also has the client
software used for the testing mentioned in the document.

http://netlab1.usu.edu/pub/misc/newpolicy.sources/

If anyone is interested, I have an Excel spreadsheet that shows some
testing I did with FreeBSD using Nagle-off, Nagle-on, and Doupnik using
HTTP requests.  It shows that Doupnik gets the same packet-size
efficiency as Nagle-on while getting better throughput than having
Nagle-off.  Let me know if you would like a copy.

I have asked Joe Doupnik for his approval to ask this community to look
at his algorithm.  He said that he would be happy to answer any
questions that anyone has on his algorithm, and if it looks like there
is a good chance that it will be included in Linux, he could code the
patch as well (from the looks of things, tcp.h has changed enough from
2.2.5-15 to current to warrant another pass to make sure the algorithm
is correctly implemented).

Joseph Conlin
