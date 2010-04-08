From: Valdis.Kletnieks@vt.edu
Subject: Re: mmotm 2010-04-05-16-09 uploaded
Date: Thu, 08 Apr 2010 11:23:17 -0400
Message-ID: <6795.1270740197@localhost>
References: <201004052336.o35NaeSE015814@imap1.linux-foundation.org> <13074.1270663309@localhost>
            <4BBDC0CC.7080305@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1270740197_3956P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lennier.cc.vt.edu ([198.82.162.213]:55290 "EHLO
	lennier.cc.vt.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753954Ab0DHPZM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 11:25:12 -0400
In-Reply-To: Your message of "Thu, 08 Apr 2010 13:41:00 +0200."
             <4BBDC0CC.7080305@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--==_Exmh_1270740197_3956P
Content-Type: text/plain; charset=us-ascii

On Thu, 08 Apr 2010 13:41:00 +0200, Patrick McHardy said:

> Valdis.Kletnieks@vt.edu wrote:
> > On Mon, 05 Apr 2010 16:09:45 PDT, akpm@linux-foundation.org said:
> >> The mm-of-the-moment snapshot 2010-04-05-16-09 has been uploaded to
> >>
> >>    http://userweb.kernel.org/~akpm/mmotm/
> > 
> > Seen in dmesg, 2.6.34-rc2-mmotm0323 didn't do this. Tossing it at all the
> > likely suspects, hopefully somebody will recognize it and save me the
> > bisecting. ;)
> > 
> > [   11.488535] ctnetlink v0.93: registering with nfnetlink.
> > [   11.488579] 
> > [   11.488579] ===================================================
> > [   11.489529] [ INFO: suspicious rcu_dereference_check() usage. ]
> > [   11.489988] ---------------------------------------------------
> > [   11.490494] net/netfilter/nf_conntrack_ecache.c:88 invoked rcu_dereference_check() without protection!
> > [   11.491024] 
> > [   11.491024] other info that might help us debug this:
> > [   11.491025] 
> > [   11.492834] 
> > [   11.492835] rcu_scheduler_active = 1, debug_locks = 0
> > [   11.494124] 1 lock held by swapper/1:
> > [   11.494776]  #0:  (nf_ct_ecache_mutex){+.+...}, at: [<ffffffff8148c606>] nf_conntrack_register_notifier+0x1a/0x76
> > [   11.495505] 
> 
> There are some unnecessary rcu_dereference() calls in the conntrack
> notifier registration and unregistration functions.
> 
> Does this fix it?

Well, it *changed* it.  Does the rcu_defererence_check() only fire on the
first time it hits something, so we've fixed the first one and now we get to
see the second one?

(For what it's worth, if this is going to be one-at-a-time whack-a-mole, I'm
OK on that, just want to know up front.)

[    9.299425] ip_tables: (C) 2000-2006 Netfilter Core Team
[    9.299486] 
[    9.299486] ===================================================
[    9.300499] [ INFO: suspicious rcu_dereference_check() usage. ]
[    9.301001] ---------------------------------------------------
[    9.301523] net/netfilter/nf_log.c:55 invoked rcu_dereference_check() without protection!
[    9.302066] 
[    9.302066] other info that might help us debug this:
[    9.302067] 
[    9.303748] 
[    9.303748] rcu_scheduler_active = 1, debug_locks = 0
[    9.304990] 1 lock held by swapper/1:
[    9.305645]  #0:  (nf_log_mutex){+.+...}, at: [<ffffffff8148427a>] nf_log_register+0x57/0x111
[    9.306342] 
[    9.306343] stack backtrace:
[    9.307729] Pid: 1, comm: swapper Not tainted 2.6.34-rc3-mmotm0405 #2
[    9.308447] Call Trace:
[    9.309170]  [<ffffffff810638c5>] lockdep_rcu_dereference+0xaa/0xb2
[    9.309935]  [<ffffffff81484301>] nf_log_register+0xde/0x111
[    9.310688]  [<ffffffff81b6064b>] ? log_tg_init+0x0/0x29
[    9.311465]  [<ffffffff81b60670>] log_tg_init+0x25/0x29
[    9.312233]  [<ffffffff810001ef>] do_one_initcall+0x59/0x14e
[    9.313030]  [<ffffffff81b3268a>] kernel_init+0x144/0x1ce
[    9.313819]  [<ffffffff81003514>] kernel_thread_helper+0x4/0x10
[    9.314625]  [<ffffffff8159cb80>] ? restore_args+0x0/0x30
[    9.315434]  [<ffffffff81b32546>] ? kernel_init+0x0/0x1ce
[    9.316224]  [<ffffffff81003510>] ? kernel_thread_helper+0x0/0x10
[    9.317037] TCP bic registered


--==_Exmh_1270740197_3956P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFLvfTlcC3lWbTT17ARAo1HAJ4yC0en5BctowrLleTYyxhKbpZ0CwCg3kzV
257B3W+JglYzXi/NAzZL1Ws=
=eqF5
-----END PGP SIGNATURE-----

--==_Exmh_1270740197_3956P--

