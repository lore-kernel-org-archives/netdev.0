From: Peter Buckingham <peter@pantasys.com>
Subject: Re: [PATCH 2.6] ipconfig accepts any DHCPACK
Date: Tue, 07 Sep 2004 15:45:06 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <413E39F2.4070708@pantasys.com>
References: <413E2C26.5040108@pantasys.com> <20040907150204.119ba849.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040907150204.119ba849.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
  > Just because there are 16 bytes of hw address in the bootp packet
> layout doesn't mean the device actually has that many.  Please fix
> it to use dev->addr_len.
> 

is this okay?

peter

Signed-off-by: Peter Buckingham <peter@pantasys.com>

--- linus-2.6/net/ipv4/ipconfig.c	2004-09-02 14:53:54.000000000 -0700
+++ local_linux/net/ipv4/ipconfig.c	2004-09-07 15:43:39.000000000 -0700
@@ -966,6 +966,11 @@ static int __init ic_bootp_recv(struct s
  				break;

  			case DHCPACK:
+				for (i = 0; (dev->dev_addr[i] == b->hw_addr[i])
+						&& (i < dev->addr_len); i++);
+				if (i < dev->addr_len)
+					goto drop_unlock;
+
  				/* Yeah! */
  				break;
