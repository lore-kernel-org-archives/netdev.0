From: Ilya Pashkovsky <ilya.pashkovsky@gmail.com>
Subject: tcp port reuse checking TCP_LISTEN state
Date: Sat, 27 Nov 2004 16:13:34 +0200
Message-ID: <fcb9aa2904112706135928497@mail.gmail.com>
References: <fcb9aa29041123022027c1ec06@mail.gmail.com>
Reply-To: Ilya Pashkovsky <ilya.pashkovsky@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <fcb9aa29041123022027c1ec06@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello, fellow developers.

While BSD (and thus, MacOS X) has the SO_REUSEPORT socket option, and
Windows has SO_REUSEADDR socket option that integrates the port reuse
functionality, linux tends to differ.
Though the socket matching should be made using the tuple consisting
of both source address+port and destination address+port, there's a
check in the tcp implementation of linux kernel for TCP_LISTEN state,
which inhibits port reuse. While its logical to allow only one
listener on a socket, this can be accomplished by checking for the
socket state during the call to listen(). The current behavior breaks
applications that want to both listen on an port and initiate outgoing
connections from it (same port).
Can anyone please explain the logic behind the TCP_LISTEN check being
done on bind() calls and not listen() calls ?

p.s. Please cc your reply directly to ilya.pashkovsky@gmail.com

--
ilya
