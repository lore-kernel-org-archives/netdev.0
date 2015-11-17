From: Jan Engelhardt <jengelh-9+2X+4sQBs8@public.gmane.org>
Subject: Re: [PATCH 2/5] kernfs: implement kernfs_walk_and_get()
Date: Tue, 17 Nov 2015 23:48:55 +0100 (CET)
Message-ID: <alpine.LSU.2.20.1511172348110.13966@nerf40.vanv.qr>
References: <1447789240-29394-1-git-send-email-tj@kernel.org> <1447789240-29394-3-git-send-email-tj@kernel.org> <20151117.162040.1412296298973879057.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
	kadlec-K40Dz/62t/MgiyqX0sVFJYdd74u8MsAO@public.gmane.org, lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	coreteam-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-team-b10kYP2dOMg@public.gmane.org,
	daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org,
	nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20151117.162040.1412296298973879057.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


On Tuesday 2015-11-17 22:20, David Miller wrote:
>> +	static char path_buf[PATH_MAX];	/* protected by kernfs_mutex */
>> +	int len = strlen(path);
> ...
>> +	if (len >= PATH_MAX)
>> +		return NULL;
>> +
>> +	memcpy(path_buf, path, len + 1);
>
>	static char path_buf[PATH_MAX];	/* protected by kernfs_mutex */
>	int len = strlcpy(path_buf, path, PATH_MAX);
> ...
>	if (len >= PATH_MAX)
>		return NULL;

	if (len < 0 || len >= PATH_MAX)

strlcpy returns a size_t, which, when coerced into an int, could lead to
negative numbers. In that sense, "size_t len" probably seems like an even
better bet yet.
