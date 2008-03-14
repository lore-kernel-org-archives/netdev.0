From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Audit vs netlink interaction problem
Date: Fri, 14 Mar 2008 19:29:27 +0100
Message-ID: <20080314182927.GQ20815@postel.suug.ch>
References: <47DAA660.90401@openvz.org> <20080314163929.GP20815@postel.suug.ch> <47DAB065.6060804@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Woodhouse <dwmw2@infradead.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758732AbYCNS33@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <47DAB065.6060804@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Pavel Emelyanov <xemul@openvz.org> 2008-03-14 20:05
> Hmmm... I'm afraid, that this can break the audit filtering and signal
> auditing. I haven't yet looked deep into it, but it compares the 
> task->tgid with this audit_pid for different purposes. If audit_pid
> changes this code will be broken.

OK, then both pids have to be stored. audit_pid remains as-is but is
no longer used as destination netlink pid. A second pid is stored and
updated whenever a netlink message is received from userspace.

> Bu we have no the netlink socket at the moment of setting the pid to
> check this. The audit_reveive_msg() call which does this set is received 
> via another (pre-created global) socket.

I don't understand this. As far as I can read the code, a plain kernel
side netlink socket is created in audit_init(). But it doesn't matter,
as soon as we receive the first message from userspace, we know the
netlink source pid.

> I though, that proper behavior would be to split audit_pid, used for
> filtering from the audit_nlk_pid used for netlink communications.

Yes, exactly.
