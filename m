From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] fixing the cases where tcp_tw_bucket was accessed as a
 sock
Date: Mon, 13 Oct 2003 12:49:30 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031013124930.0e75a325.davem@redhat.com>
References: <20031012131344.GH16182@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
In-Reply-To: <20031012131344.GH16182@conectiva.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 12 Oct 2003 10:13:44 -0300
Arnaldo Carvalho de Melo <acme@conectiva.com.br> wrote:

> 	The WARN_ON is just to be paranoid for a while, I should have done
> that a loooong time ago :-\

I appreciate the intentions here but the resulting code is
really a mess.  We have this thing now in in.h called
"inet_something()" that tests TCP state, and then we have
something similar for ipv6 in addrconf.c  :-)

Let's do one thing at a time.  First, fix the original bug
in tcp_ipv4.c by just putting your inet_rcv_saddr() shorthand
right there in tcp_ipv4.c and name it tcp4_rcv_saddr() or
something like that.

Then we can move onto the rest of the changes and try to find
a common place for the helper routines.

See what happens when you try to do too many things at one
time :-)
