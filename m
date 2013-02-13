From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH v4 1/9] rdma/cm: define native IB address
Date: Wed, 13 Feb 2013 14:56:02 +0200
Message-ID: <511B8D62.3050508@mellanox.com>
References: <1358891797-14625-1-git-send-email-sean.hefty@intel.com> <1358891797-14625-2-git-send-email-sean.hefty@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-rdma@vger.kernel.org>, <netdev@vger.kernel.org>
To: <sean.hefty@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:34726 "HELO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932549Ab3BMM4H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2013 07:56:07 -0500
In-Reply-To: <1358891797-14625-2-git-send-email-sean.hefty@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22/01/2013 23:56, sean.hefty@intel.com wrote:
> +
> +struct sockaddr_ib {
> +	unsigned short int	sib_family;	/* AF_IB */
> +	__be16			sib_pkey;
> +	__be32			sib_flowinfo;
> +	struct ib_addr		sib_addr;
> +	__be64			sib_sid;
> +	__be64			sib_sid_mask;
> +	__u64			sib_scope_id;
> +};

just a nit, maybe reorder the fields to better cope with their IPv6 
buddies (where  there is
such) from sockaddr_in6?

Also I see that both IPv6 header and IB GRH have a traffic class field 
which is skipped in both
cases for the related sockaddr_ structure, not sure why, is this 
something the kernel stack decides on and uses but not available for 
applications to read/modify?

struct sockaddr_in6 {
         unsigned short int      sin6_family;    /* AF_INET6 */
         __be16                  sin6_port;      /* Transport layer port 
# */
         __be32                  sin6_flowinfo;  /* IPv6 flow information */
         struct in6_addr         sin6_addr;      /* IPv6 address */
         __u32                   sin6_scope_id;  /* scope id (new in 
RFC2553) */
};
