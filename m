From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] cgroup: net_cls: fix false-positive "suspicious RCU
 usage"
Date: Tue, 21 Jul 2015 22:28:58 -0700 (PDT)
Message-ID: <20150721.222858.1855944921733592230.davem@davemloft.net>
References: <20150721164629.18385.14538.stgit@buzz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: khlebnikov-XoJtRXgx1JseBXzfvpsJ4g@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150721164629.18385.14538.stgit@buzz>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Konstantin Khlebnikov <khlebnikov-XoJtRXgx1JseBXzfvpsJ4g@public.gmane.org>
Date: Tue, 21 Jul 2015 19:46:29 +0300

> @@ -23,7 +23,8 @@ static inline struct cgroup_cls_state *css_cls_state(struct cgroup_subsys_state
>  
>  struct cgroup_cls_state *task_cls_state(struct task_struct *p)
>  {
> -	return css_cls_state(task_css(p, net_cls_cgrp_id));
> +       return css_cls_state(task_css_check(p, net_cls_cgrp_id,
> +			       rcu_read_lock_bh_held()));

You've made a serious mess of the indentation here.

First of all, you've changed the correct plain "TAB" before the 'return' line
into a TAB and two SPACE characters.

Secondly, the second line needs to be precisely indented to the exact column
following the openning parenthesis of the task_css_check() call on the
previous line.
