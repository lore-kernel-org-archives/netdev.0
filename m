From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: pktgen (was Re: tests of kernel modules)
Date: Wed, 22 Nov 2006 00:22:51 +0300
Message-ID: <20061121212251.GA5084@martell.zuzino.mipt.ru>
References: <20061121174737.GA5220@martell.zuzino.mipt.ru> <9fa31860611211236i104cb510mb5100ea056b657db@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:63113 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1161145AbWKUVWy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Nov 2006 16:22:54 -0500
Received: by nf-out-0910.google.com with SMTP id o25so298494nfa
        for <netdev@vger.kernel.org>; Tue, 21 Nov 2006 13:22:53 -0800 (PST)
To: Pavol Gono <pavol.gono@gmail.com>
Content-Disposition: inline
In-Reply-To: <9fa31860611211236i104cb510mb5100ea056b657db@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[CCing netdev, bug in pktgen]

	[build modular pktgen]
	while true; do modprobe pktgen && rmmod pktgen; done

	BUG: warning at fs/proc/generic.c:732/remove_proc_entry()
	 [<c016a7ad>] remove_proc_entry+0x161/0x1ca
	 [<e19969ab>] pg_cleanup+0xd5/0xdc [pktgen]
         [<c011fa3e>] autoremove_wake_function+0x0/0x35
	 [<c01280bd>] sys_delete_module+0x162/0x189
	 [<c0136500>] remove_vma+0x31/0x36
	 [<c0136df7>] do_munmap+0x193/0x1ac
	 [<c0102829>] sysenter_past_esp+0x56/0x79
	 [<c02d007b>] fn_hash_delete+0x4f/0x1c7

On Tue, Nov 21, 2006 at 09:36:46PM +0100, Pavol Gono wrote:
> I am going to add two more:
> for i in 1 2 3 4 5 ; do modprobe pktgen ; rmmod pktgen ; done

Looks like it creates /proc/net/pktgen/kpktgen_%i but forgets to remove
them.

