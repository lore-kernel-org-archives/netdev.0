From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] UDPCP Communication Protocol
Date: Fri, 31 Dec 2010 09:46:34 -0800
Message-ID: <20101231094634.5b96e0d1@s6510>
References: <1293787785-3834-1-git-send-email-stefani@seibold.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org
To: stefani@seibold.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1293787785-3834-1-git-send-email-stefani@seibold.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 31 Dec 2010 10:29:45 +0100
stefani@seibold.net wrote:

> +struct __attribute__ ((packed)) udpcphdr {
> +	struct udphdr udphdr;
> +	__be32 chksum;
> +	__be16 msginfo;
> +	u8 fragamount;
> +	u8 fragnum;
> +	__be16 msgid;
> +	__be16 length;
> +};

Adding (unnecessary) packed attribute will make access slow on
some architectures. For arch that can't do unaligned access, the
compiler ends up doing byte access for each element.
