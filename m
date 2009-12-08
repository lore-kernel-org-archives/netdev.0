From: Li Zefan <lizf@cn.fujitsu.com>
Subject: Re: [RFC] [PATCH 3/5] cgroups: net_cls as module
Date: Tue, 08 Dec 2009 14:07:50 +0800
Message-ID: <4B1DED36.8080204@cn.fujitsu.com>
References: <20091204085349.GA18867@andrew.cmu.edu> <20091204085712.GC18912@andrew.cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	containers@lists.linux-foundation.org, akpm@linux-foundation.org,
	menage@google.com, netdev@vger.kernel.org
To: Ben Blum <bblum@andrew.cmu.edu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S935792AbZLHGIO@vger.kernel.org>
In-Reply-To: <20091204085712.GC18912@andrew.cmu.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +struct cgroup_subsys net_cls_subsys = {
> +	.name		= "net_cls",
> +	.create		= cgrp_create,
> +	.destroy	= cgrp_destroy,
> +	.populate	= cgrp_populate,
> +#ifdef CONFIG_NET_CLS_CGROUP
> +	.subsys_id	= net_cls_subsys_id,
> +#else
> +#define net_cls_subsys_id net_cls_subsys.subsys_id
> +#endif

This looks a bit odd. I think below is the more standard way:

#ifndef MODULES
...
#else
...
#endif

> +	.module		= THIS_MODULE,
> +};
