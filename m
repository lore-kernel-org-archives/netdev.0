From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next v2 6/6] net_sched: convert tcf_hashinfo to
 hlist and use rcu
Date: Fri, 13 Dec 2013 05:18:59 +0000 (UTC)
Message-ID: <slrnlal66e.3h5.xiyou.wangcong@linux-6brj.site>
References: <1386910604-1870-1-git-send-email-xiyou.wangcong@gmail.com>
 <1386910604-1870-7-git-send-email-xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:60931 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750926Ab3LMFTZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Dec 2013 00:19:25 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1VrL9o-0001lw-0O
	for netdev@vger.kernel.org; Fri, 13 Dec 2013 06:19:24 +0100
Received: from c-24-5-209-215.hsd1.ca.comcast.net ([24.5.209.215])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 13 Dec 2013 06:19:24 +0100
Received: from xiyou.wangcong by c-24-5-209-215.hsd1.ca.comcast.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 13 Dec 2013 06:19:24 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 13 Dec 2013 at 04:56 GMT, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>  {
> -	rwlock_init(&hf->lock);
> +	int i;
> +
> +	spin_lock_init(&hf->lock);
>  	hf->hmask = mask;
>  	hf->htab = kzalloc((mask + 1) * sizeof(struct tcf_common *),
>  			   GFP_KERNEL);
>  	if (!hf->htab)
>  		return -ENOMEM;
> +	for (i = 0; i < mask + 1; i++)
> +		INIT_HLIST_HEAD(&hf->htab[i]);
>  	return 0;

Oops, a new bug was introduced during my rebase...
