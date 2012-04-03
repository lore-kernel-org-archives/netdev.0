From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH 3/3] netfilter: xt_CT: remove a compile warning
Date: Tue, 3 Apr 2012 20:48:21 +0900
Message-ID: <201204032048.GFH51564.QSOVLMOOJHtFFF@I-love.SAKURA.ne.jp>
References: <1333448001-2507-1-git-send-email-pablo@netfilter.org>
	<1333448001-2507-4-git-send-email-pablo@netfilter.org>
	<201204031927.AIJ09351.FQFMJOOVFSOtHL@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:65497 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751974Ab2DCLs0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 07:48:26 -0400
In-Reply-To: <201204031927.AIJ09351.FQFMJOOVFSOtHL@I-love.SAKURA.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

One more question.

Tetsuo Handa wrote:
> 216 #ifdef CONFIG_NF_CONNTRACK_TIMEOUT
> 217         if (info->timeout) {
> 218                 typeof(nf_ct_timeout_find_get_hook) timeout_find_get;
> 219                 struct ctnl_timeout *timeout;
> 220                 struct nf_conn_timeout *timeout_ext;
> 221 
> 222                 rcu_read_lock();
> 223                 timeout_find_get =
> 224                         rcu_dereference(nf_ct_timeout_find_get_hook);
> 225 
> 226                 if (timeout_find_get) {

I assume timeout_find_get points to e.g. ctnl_timeout_find_get in
net/netfilter/nfnetlink_cttimeout.c . If yes,

> 227                         const struct ipt_entry *e = par->entryinfo;
> 228                         struct nf_conntrack_l4proto *l4proto;
> 229 
> 230                         if (e->ip.invflags & IPT_INV_PROTO) {
> 231                                 ret = -EINVAL;
> 232                                 pr_info("You cannot use inversion on "
> 233                                          "L4 protocol\n");
> 234                                 goto err4;
> 235                         }
> 236                         timeout = timeout_find_get(info->timeout);
> 237                         if (timeout == NULL) {
> 238                                 ret = -ENOENT;
> 239                                 pr_info("No such timeout policy \"%s\"\n",
> 240                                         info->timeout);
> 241                                 goto err4;
> 242                         }

I think "goto err4;" after successful timeout_find_get() wants e.g.
nf_ct_timeout_put_hook call (e.g. ctnl_timeout_put()).

> 243                         if (timeout->l3num != par->family) {
> 244                                 ret = -EINVAL;
> 245                                 pr_info("Timeout policy `%s' can only be "
> 246                                         "used by L3 protocol number %d\n",
> 247                                         info->timeout, timeout->l3num);
> 248                                 goto err4;
> 249                         }
