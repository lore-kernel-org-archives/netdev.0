From: kuznet@ms2.inr.ac.ru
Subject: Re: Fw: Re: [PATCH] ipv4 tcp autobind problem
Date: Tue, 7 Oct 2003 15:56:41 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310071156.PAA31530@yakov.inr.ac.ru>
References: <3F7990FB.7030606@balabit.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com (David S. Miller), jmorris@redhat.com, netdev@oss.sgi.com,
        linux-net@vger.rutgers.edu, bazsi@balabit.hu (Balazs Scheidler)
Return-path: <netdev-bounce@oss.sgi.com>
To: hidden@balabit.hu (Kovacs Krisztian)
In-Reply-To: <3F7990FB.7030606@balabit.hu> from "Kovacs Krisztian" at Сен 30, 2003 04:19:39 
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> - When the socket is closed (inet_release() is called, tproxy has its 
> "callback" function here), the corresponding entries are deleted from 
> tproxy's hash tables, again, based on the local ip:port pair.

The mistake is here. inet_release() has nothing to do to connection
state. Socket is not closed at this point, it goes to FIN-WAIT*, LAST-ACK or
something like this and can exist for long time after this and proxying
is to be continued all this time.

Right place to finish tracking is when socket is removed from TCP
hash tables, and to start tracking is when the socket is inserted
to TCP hash tables. BTW you would not see the problem with binding
if it was made right.

Alexey
