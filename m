From: "David S. Miller" <davem@redhat.com>
Subject: Re: [rfc] sk_write_space() for atm
Date: Tue, 24 Jun 2003 16:35:17 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030624.163517.15237390.davem@redhat.com>
References: <200306241735.h5OHZCsG004098@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: chas3@users.sourceforge.net, chas@cmf.nrl.navy.mil
In-Reply-To: <200306241735.h5OHZCsG004098@ginger.cmf.nrl.navy.mil>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: chas williams <chas@cmf.nrl.navy.mil>
   Date: Tue, 24 Jun 2003 13:33:05 -0400

   i am thinking about the following for the atm protocol.
   the writable for atm has always been when you have enough
   space to send the next pdu.  i suppose this should be 
   preserved to be completely compat, but it might not be the
   best choice.  poll is interesting also.  it seems to me
   that vcc->reply should be atleast copied, since it could
   change during the poll function (or so i imagine).  its
   probably a better idea to just change WAITING to be a bit
   inside vcc->flags and remove vcc->error in favor of sk->sk_err.
   
You can achieve what you want with 'reply' via:

	reply = vcc->reply;
	barrier();

the code you have there will merely make gcc go to the
stack for 'reply' every time it is used and that's obviously
not what you want, you want a singular snapshot of vcc->reply.

This doesn't guarentee anything, if you want to test multiple
pieces of state and make a decision based upon a snapshot of
them you must do some more serious locking (such as lock_sock())
in the poll function.
