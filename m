From: Martin Pool <mbp@samba.org>
Subject: Re: FIN_WAIT1 / TCP_CORK / 2.2 -- reproducible bug and test case
Date: Wed, 18 Sep 2002 12:30:14 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020918023012.GC2285@samba.org>
References: <20020918020346.GA2285@samba.org> <20020917.185801.76605813.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ak@muc.de, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, Alan.Cox@linux.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20020917.185801.76605813.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

For what it's worth, I can also reproduce the bug on 2.2.22rc3.  It's
on a non-SMP machine with a very standard kernel config, no
firewalling, Debian 2.2.  

I'm testing it under VMWare, but the same symptoms were observed by
other people on real hardware with Red Hat 6.2.  It was originally
noticed in distcc, and this test case is basically just a
stripped-down version of the same code.

If the program uncorks the socket before closing it, then it cleans up
properly.  However, if distcc is killed, then it can't do that and the
problem occurs.  (The most recent version makes an effort to always
uncork, but obviously for e.g. SIGKILL it can't do much other than
avoid corks entirely.)  Some people observed a couple of hundred (?)
sockets getting into this state.

-- 
Martin 
