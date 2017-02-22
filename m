From: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: [PATCH rfc 1/4] net/utils: generic inet_pton_with_scope helper
Date: Tue, 21 Feb 2017 23:43:54 -0800
Message-ID: <20170222074354.GA19012@infradead.org>
References: <1487267017-29904-1-git-send-email-sagi@grimberg.me>
 <1487267017-29904-2-git-send-email-sagi@grimberg.me>
 <20170219171523.GC10310@infradead.org>
 <6c2a4f67-ede6-0ee1-5a90-14023994d029@grimberg.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
        linux-nvme-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        target-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Sagi Grimberg <sagi-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <6c2a4f67-ede6-0ee1-5a90-14023994d029-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 21, 2017 at 11:18:04PM +0200, Sagi Grimberg wrote:
> I can maybe do something like:
> 
> if (af == AF_INET || af == AF_UNSPEC) {
> 	ret = inet4_pton();
> 	if (!ret)
> 		return 0;
> 	else if (af != AF_UNSPEC)
> 		return ret;
> }
> 
> if (af == AF_INET6 || af == AF_UNSPEC) {
> 	ret = inet6_pton();
> 	if (!ret)
> 		return 0;
> 	else if (af != AF_UNSPEC)
> 		return ret;
> }
> 
> return -EINVAL;
> 
> better?

My idead was the following:

	switch (af) {
	case AF_INET:
		ret = inet_pton();
		break;
	case AF_INET6:
		ret = inet6_pton();
		break;
	case AF_UNSPEC:
		ret = inet6_pton();
		if (ret)
			ret = inet_pton();
		break;
	}
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
