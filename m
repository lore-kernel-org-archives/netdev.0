From: Nagendra Singh Tomar <nagendra_tomar@adaptec.com>
Subject: Re: udp_recvmsg: possible bug causing infinite hang?
Date: Tue, 12 Oct 2004 11:02:51 +0530 (IST)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.44.0410121052390.29592-100000@localhost.localdomain>
References: <20041009184503.7fc5c105.davem@davemloft.net>
Reply-To: "Tomar, Nagendra" <nagendra_tomar@adaptec.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Chad N. Tindel" <ctindel@falcon.csc.calpoly.edu>,
	<netdev@oss.sgi.com>, <linux-net@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041009184503.7fc5c105.davem@davemloft.net>
List-Id: netdev.vger.kernel.org

On Sat, 9 Oct 2004, David S. Miller wrote:

> Select() returning that a filedescriptor is readable does not
> guarentee that a blocking socket will not block in the ead
> call.
> 

Does the POSIX standard _not_ give this implicit guarantee ? Whats the 
point in having a select call that says that the fd is readable, and when 
I go to read it the blocking read call blocks. Then either select returned 
a wrong positive or the read is buggy. 
	The kernel should mark the socket readable (and hence select returns 
"readable") only after it has added the incoming data to the socket receive 
queue or it has changed the state of the socket (in case of TCP connections 
getting closed), in case of peer closing the connection.
After that has been done, is the guarantee not there ?

Thanx,
tomar

-- You have moved the mouse. Windows must be restarted for the 
   changes to take effect.

