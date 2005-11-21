From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: netlink nlmsg_pid supposed to be pid or tid?
Date: Tue, 22 Nov 2005 01:49:13 +0300
Message-ID: <20051121224913.GA31287@ms2.inr.ac.ru>
References: <438220C3.4040602@nortel.com> <E1EeIcx-0006i3-00@gondolin.me.apana.org.au> <20051121213549.GA28187@ms2.inr.ac.ru> <4382406D.1040508@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751238AbVKUWti@vger.kernel.org>
To: Christopher Friesen <cfriesen@nortel.com>
Content-Disposition: inline
In-Reply-To: <4382406D.1040508@nortel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> TIPC wants the user to fill in the pid to use in the nlmsghdr portion of 
> a particular message.

It is wrong. netlink_pid used not to be associated with process pids.
Kernel used pid just as a seed to calculate a random value to bind,
when user did not bind explicitly. It is equal to current->pid occasionally.
F.e. libnetlink from iproute autobinds and gets netlink_pid with
getsockname().

When user binds the socket himself, he was free to bind to any value,
including pid and tgid.

Actually, I remember one discussion. Herbert, wait a minute...
That's it: February 2005, Subject: [PATCH] Add audit uid to netlink credentials
We decided (or not?) that binding to anything but tgid and pid
must be prohibited by security reasons. Apaprently, the finding was lost.

Alexey
