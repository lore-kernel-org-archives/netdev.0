From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH] dccp: missing destroy of percpu counter variable while
	unload module
Date: Wed, 5 Aug 2009 22:18:09 +0200
Message-ID: <20090805201808.GA32333@gerrit.erg.abdn.ac.uk>
References: <4A793867.3030104@cn.fujitsu.com> <4A793BE8.1060101@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dccp@vger.kernel.org, Netdev <netdev@vger.kernel.org>,
	oakad@yahoo.com
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:53662 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751623AbZHEUSU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Aug 2009 16:18:20 -0400
Content-Disposition: inline
In-Reply-To: <4A793BE8.1060101@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| > WARNING: at lib/list_debug.c:26 __list_add+0x27/0x5c()
| > Hardware name: VMware Virtual Platform
| > list_add corruption. next->prev should be prev (c080c0c4), but was (null). (next
| > =ca7188cc).
| > Modules linked in: dccp(+) nfsd lockd nfs_acl auth_rpcgss exportfs sunrpc
| > Pid: 1956, comm: modprobe Not tainted 2.6.31-rc5 #55
| > Call Trace:
| >  [<c042f8fa>] warn_slowpath_common+0x6a/0x81
| >  [<c053a6cb>] ? __list_add+0x27/0x5c
| >  [<c042f94f>] warn_slowpath_fmt+0x29/0x2c
| >  [<c053a6cb>] __list_add+0x27/0x5c
| >  [<c053c9b3>] __percpu_counter_init+0x4d/0x5d
| >  [<ca9c90c7>] dccp_init+0x19/0x2ed [dccp]
| >  [<c0401141>] do_one_initcall+0x4f/0x111
| >  [<ca9c90ae>] ? dccp_init+0x0/0x2ed [dccp]
| >  [<c06971b5>] ? notifier_call_chain+0x26/0x48
| >  [<c0444943>] ? __blocking_notifier_call_chain+0x45/0x51
| >  [<c04516f7>] sys_init_module+0xac/0x1bd
| >  [<c04028e4>] sysenter_do_call+0x12/0x22
| > 
| > Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
| > ---

Thanks a lot -- I have added this to the test-tree (which is still
2.6.31-rc1), until the patch is in net-2.6,

http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=dccp_exp.git;a=shortlog;h=dccp
 git://eden-feed.erg.abdn.ac.uk/dccp_exp        [subtree dccp]

I am wondering whether there is a relationship with 
http://bugzilla.kernel.org/show_bug.cgi?id=13692

and am cc:ing Alex Dubov, who reported it.
