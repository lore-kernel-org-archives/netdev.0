From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] Extend netlink error codes
Date: Sat, 11 Sep 2004 19:57:52 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040911175752.GE21181@postel.suug.ch>
References: <20040910225158.GO20088@postel.suug.ch> <20040911155839.GN4431@wotan.suse.de> <20040911162433.GC21181@postel.suug.ch> <20040911165056.GQ4431@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
Content-Disposition: inline
In-Reply-To: <20040911165056.GQ4431@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Andi Kleen <20040911165056.GQ4431@wotan.suse.de> 2004-09-11 18:50
> I was thinking about a variable length netlink packet
> that contains it and that is sent back to the application.  

All solutions discussed so far are based on sending a netlink
message back to the application. Changing the existing
nlmsgerr.error or adding a TLV with an error message doesn't
make much difference from an implementors view.

> No need to store it anywhere else.

Not storing it would mean to call netlink_ack from everywhere
which requires knowledge of the original netlink skb and the
original netlink message in order to get the pid and sequence
number right. (We can't use the pid assigned to the peer's
sock.) It would also mean to set a bit to avoid sending out
the ack again. Wrong?

> On the other hand there are not 
> that many sched/cls modules and some minor changes to them
> are probably ok.

True, but also think of xfrm, tcp_diag, netfilter, dnrmg. I haven't
checked how much work it would actually be to improve better
error messages for them but I plan to at least extend all
error codes related to the data passed via a netlink socket.

Will wait for some comments. I guess I would be swamped with
something like discussed above.
