From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: RE: Linux 2.4.27 SECURITY BUG - TCP Local
	andREMOTE(verified)Denial of Service Attack
Date: Mon, 13 Sep 2004 11:49:10 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095072549.14359.3.camel@localhost.localdomain>
References: <002b01c498ff$c4619b30$0200a8c0@wolf>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: peter@mysql.com, netdev@oss.sgi.com, kaukasoi@elektroni.ee.tut.fi
Return-path: <netdev-bounce@oss.sgi.com>
To: Wolfpaw - Dale Corse <admin@wolfpaw.net>
In-Reply-To: <002b01c498ff$c4619b30$0200a8c0@wolf>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sul, 2004-09-12 at 20:36, Wolfpaw - Dale Corse wrote:
> Mysql connection: descriptor 3 (from mysql.net.fd)
> Mysql connection closed (desc 3) (goes into CLOSE_WAIT now)
> New connection (outbound) for regular proxy on Desc 3
>   (this was created by a call to socket, and then connect)

fd != socket. Thats really important to realise. What you get on 
fd 3 from the new connection isn't the same as you had before. 
The one you closed has been handed off to the kernel to clean up
as and when everyone who has a copy has finished using it. Thats
why I asked about fork() - because you can end up giving handles
by mistake to other processes you create which don't close them

> The other bug being, if I simply leave them, in a short time, MySQL
> is saying "too many connections", and we can't query any data from
> it. This also occurs with FIFO sockets (such as /tmp/mysql.sock)
> wherein the connection simply sits as "ESTABLISHED".

I'd say your code is buggy then

> So something needs to trigger a "flush" of the left over data
> on the SQL side before closing the connection - yes?

That will occur anyway for you. I think you need to find out where the
other copies of the same fd went and how mysql manages them
