From: Peter Buckingham <peter@pantasys.com>
Subject: Re: [PATCH 2.6] ipconfig accepts any DHCPACK
Date: Tue, 07 Sep 2004 17:18:17 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <413E4FC9.8070800@pantasys.com>
References: <413E2C26.5040108@pantasys.com>	 <20040907150204.119ba849.davem@redhat.com>  <413E39F2.4070708@pantasys.com> <1094602330.3076.2.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David S Miller <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Joe Perches <joe@perches.com>
In-Reply-To: <1094602330.3076.2.camel@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Joe Perches wrote:
> 	if (memcmp(dev->dev_addr, b->hw_addr, dev->addr_len)!=0)
> 		goto drop_unlock;
> 

I prefer this one.

Signed-off-by: Peter Buckingham <peter@pantasys.com>

--- linus-2.6/net/ipv4/ipconfig.c	2004-09-02 14:53:54.000000000 -0700
+++ local_linux/net/ipv4/ipconfig.c	2004-09-07 17:16:55.000000000 -0700
@@ -966,6 +966,9 @@ static int __init ic_bootp_recv(struct s
  				break;

  			case DHCPACK:
+				if (memcmp(dev->dev_addr, b->hw_addr, dev->addr_len) != 0)
+					goto drop_unlock;
+
  				/* Yeah! */
  				break;
