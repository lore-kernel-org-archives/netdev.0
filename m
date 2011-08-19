From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] Scm: Remove unnecessary pid & credential references in
 Unix socket's send and receive path
Date: Thu, 18 Aug 2011 22:04:32 -0700 (PDT)
Message-ID: <20110818.220432.1711182086933489213.davem@davemloft.net>
References: <1313625374.2576.2908.camel@schen9-DESK>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, viro@zeniv.linux.org.uk,
	ebiederm@xmission.com, ak@linux.intel.com,
	matt.fleming@linux.intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: tim.c.chen@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1313625374.2576.2908.camel@schen9-DESK>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tim Chen <tim.c.chen@linux.intel.com>
Date: Wed, 17 Aug 2011 16:56:14 -0700

> +static __inline__ void scm_release(struct scm_cookie *scm)
> +{
> +	/* keep ref on pid and cred */
> +	scm->pid = NULL;
> +	scm->cred = NULL;
> +	if (scm && scm->fp)
> +		__scm_destroy(scm);
> +}

After dereferencing scm-> already, it seems a big redundant to test
it subsequently against NULL.
