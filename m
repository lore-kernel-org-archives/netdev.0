From: Jesper Dangaard Brouer <hawk-dAYI7NvHqcQ@public.gmane.org>
Subject: Re: [PATCH 5/5] sunrpc/auth_gss: Call rcu_barrier() on module unload.
Date: Mon, 8 Jun 2009 21:48:54 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0906082128240.1180@ask.diku.dk>
References: <20090608130959.10052.54590.stgit@localhost>
 <20090608131148.10052.39869.stgit@localhost>  <20090608162656.GF6961@linux.vnet.ibm.com>
 <1244480449.5040.4.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, Jesper Dangaard Brouer <hawk-4UpuNZONu4c@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1244480449.5040.4.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


(trimmed Cc)

On Mon, 8 Jun 2009, Trond Myklebust wrote:

> Hmm... If this is about ensuring that all the call_rcu() callbacks
> complete before we remove the module, then don't we also need similar
> barriers in

Well, Trond that was a hard question, as I don't know this code... but if 
it uses call_rcu() callbacks its most likely.

I have not done a complete sweep of the tree, I have only looked at the 
netdev parts, as this is where I usually snoop around.  So there is 
probably plenty of work for some kernel-janitors (Cc'ing the list ;-))

> net/sunrpc/sunrpc_syms.c:cleanup_sunrpc()

Looking at the code that end up in sunrpc.ko, I see that both 
net/sunrpc/auth_unix.c and net/sunrpc/auth_generic.c uses call_rcu() 
callbacks.

> and in fs/nfs/inode.c:exit_nfs_fs()?

Looking at the code which end up into nfs.ko (which includes 
fs/nfs/inode.c) I see that the fs/nfs/delegation.c uses call_rcu() 
callbacks.

But its hard for me to figure out how this code interacts.  Don't know if 
we need to document a code path that can occur fast enough, before we add 
this safe guard?  It should be Paul's saying...

Cheers,
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
