From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] kernfs: implement kernfs_walk_and_get()
Date: Tue, 17 Nov 2015 16:20:40 -0500 (EST)
Message-ID: <20151117.162040.1412296298973879057.davem@davemloft.net>
References: <1447789240-29394-1-git-send-email-tj@kernel.org>
	<1447789240-29394-3-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	lizefan@huawei.com, hannes@cmpxchg.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com, daniel@iogearbox.net,
	daniel.wagner@bmw-carit.de, nhorman@tuxdriver.com,
	gregkh@linuxfoundation.org
To: tj@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447789240-29394-3-git-send-email-tj@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tejun Heo <tj@kernel.org>
Date: Tue, 17 Nov 2015 14:40:37 -0500

> +	static char path_buf[PATH_MAX];	/* protected by kernfs_mutex */
> +	int len = strlen(path);
 ...
> +	if (len >= PATH_MAX)
> +		return NULL;
> +
> +	memcpy(path_buf, path, len + 1);

	static char path_buf[PATH_MAX];	/* protected by kernfs_mutex */
	int len = strlcpy(path_buf, path, PATH_MAX);
 ...
	if (len >= PATH_MAX)
		return NULL;
