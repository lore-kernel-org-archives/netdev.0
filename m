From: Patrick McHardy <kaber@trash.net>
Subject: Re: netfilter 00/29: Netfilter Update
Date: Thu, 27 Nov 2008 17:16:00 +0100
Message-ID: <492EC7C0.4040009@trash.net>
References: <20081127161503.13891.62766.sendpatchset@x2.localnet>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080201070909000605070502"
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20081127161503.13891.62766.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080201070909000605070502
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> There's a trivial merge conflict in net/netfilter/nf_conntrack_netlink.c,
> so the patches won't apply directly. Please pull from
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-next-2.6.git

And for reference, this is what I did to resolve the conflict:


--------------080201070909000605070502
Content-Type: text/x-patch;
 name="conflict.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="conflict.diff"

commit dbfaaa37cdfb579e317e2498eb2fc634be178761
Merge: 5b9ab2e... d6e8cc6...
Author: Patrick McHardy <kaber@trash.net>
Date:   Thu Nov 27 16:28:34 2008 +0100

    Merge branch 'master' of /home/kaber/src/nf/nf-next-2.6
    
    Conflicts:
    
    	net/netfilter/nf_conntrack_netlink.c

diff --cc net/netfilter/nf_conntrack_netlink.c
index 5f4a651,ccc5ef1..a0c9bc4
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@@ -1087,10 -1131,9 +1131,9 @@@ ctnetlink_create_conntrack(struct nlatt
  {
  	struct nf_conn *ct;
  	int err = -EINVAL;
- 	struct nf_conn_help *help;
  	struct nf_conntrack_helper *helper;
  
 -	ct = nf_conntrack_alloc(&init_net, otuple, rtuple, GFP_KERNEL);
 +	ct = nf_conntrack_alloc(&init_net, otuple, rtuple, GFP_ATOMIC);
  	if (ct == NULL || IS_ERR(ct))
  		return -ENOMEM;
  
@@@ -1209,17 -1294,18 +1294,19 @@@ ctnetlink_new_conntrack(struct sock *ct
  				goto out_unlock;
  			}
  			master_ct = nf_ct_tuplehash_to_ctrack(master_h);
- 			atomic_inc(&master_ct->ct_general.use);
+ 			nf_conntrack_get(&master_ct->ct_general);
  		}
  
 -		spin_unlock_bh(&nf_conntrack_lock);
  		err = -ENOENT;
  		if (nlh->nlmsg_flags & NLM_F_CREATE)
  			err = ctnetlink_create_conntrack(cda,
  							 &otuple,
  							 &rtuple,
- 							 master_ct);
+ 							 master_ct,
+ 							 NETLINK_CB(skb).pid,
+ 							 nlmsg_report(nlh));
 +		spin_unlock_bh(&nf_conntrack_lock);
 +
  		if (err < 0 && master_ct)
  			nf_ct_put(master_ct);
  

--------------080201070909000605070502--
