From: "Paul Albrecht" <palbrecht@qwest.net>
Subject: Re: question about linux tcp request queue handling
Date: Sun, 6 Jul 2003 23:20:42 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <000d01c3444f$e6439600$6801a8c0@oemcomputer>
References: <3F08858E.8000907@us.ibm.com> <001a01c3441c$6fe111a0$6801a8c0@oemcomputer> <3F08B7E2.7040208@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, "netdev" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Nivedita Singhvi" <niv@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Nivedita Singhvi writes:

>
> When you set a the backlog to 1 in the listen call, what is
> being capped is the accept queue. So I would expect your
> server to allow only one of those requests in the accept
> queue, and the kernel will drop the other two requests.
>

What you get when you set backlog to one is operating system dependent.
Tracing the flows with tcpdump, I get two clean handshakes so presumeably,
for linux, one means two.  The third connection request *isn't* dropped;
according to netstat, it's placed in the syn_recd state.  I thought
berkeley-derived implementations followed the rule that if there is no room
on the backlog queue for the new connection, tcp ignored the the received
syn.

>
> Actually, details, but we also apply some other conditions
> before we actually drop the connection request - we try not to be
> so harsh if the syn queue is still fairly empty..
>

Irrespective of whatever conditions linux applies, how can the connection
enter the syn_recd state if the backlog limit would be exceeded?  What's the
client supposed to do with the syn/ack from the server? What's the server
supposed to do with the ack it get's back from the client?
