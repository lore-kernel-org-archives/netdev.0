From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 2.6] ipconfig accepts any DHCPACK
Date: Tue, 07 Sep 2004 17:12:11 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1094602330.3076.2.camel@localhost.localdomain>
References: <413E2C26.5040108@pantasys.com>
	 <20040907150204.119ba849.davem@redhat.com>  <413E39F2.4070708@pantasys.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David S Miller <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Peter Buckingham <peter@pantasys.com>
In-Reply-To: <413E39F2.4070708@pantasys.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-09-07 at 15:45, Peter Buckingham wrote: 
> is this okay?
> +				for (i = 0; (dev->dev_addr[i] == b->hw_addr[i])
> +						&& (i < dev->addr_len); i++);
> +				if (i < dev->addr_len)
> +					goto drop_unlock;
> +

I had to read that twice.

How about something like:

	for (i=0;i<dev->addr_len;i++)
		if (dev->dev_addr[i] != b->hw_addr[i])
			goto drop_unlock;

or

	if (memcmp(dev->dev_addr, b->hw_addr, dev->addr_len)!=0)
		goto drop_unlock;

instead?
