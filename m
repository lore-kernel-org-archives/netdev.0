From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: question about linux tcp request queue handling
Date: Sun, 06 Jul 2003 16:59:30 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F08B7E2.7040208@us.ibm.com>
References: <3F08858E.8000907@us.ibm.com> <001a01c3441c$6fe111a0$6801a8c0@oemcomputer>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Paul Albrecht <palbrecht@qwest.net>
In-Reply-To: <001a01c3441c$6fe111a0$6801a8c0@oemcomputer>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Paul Albrecht wrote:

> My server program sets its backlog to one and pauses ninety seconds before
> accepting connections.  Within that ninety second interval, I start three
> client programs that do an active open to my server.  I expect one of
> connections to get discarded when the server's connection backlog limit is
> exceeded.

We actually have two queues - the syn queue and the socket
acccept queue. We move the connection request from the syn
queue to the accept queue of the socket once the 3 way
handshake is complete - i.e. once the state is ESTABLISHED.

If the syn queue is full, requests will get dropped and
the socket will not change state.

When you set a the backlog to 1 in the listen call, what is
being capped is the accept queue. So I would expect your
server to allow only one of those requests in the accept
queue, and the kernel will drop the other two requests.

Actually, details, but we also apply some other conditions
before we actually drop the connection request - we try not to be
so harsh if the syn queue is still fairly empty..

Think thats so, at any rate :).

Nivedita
