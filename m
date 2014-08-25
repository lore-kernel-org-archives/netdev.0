From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [hyperv] BUG at drivers/hv/channel.c:462 while changing MTU
Date: Mon, 25 Aug 2014 12:36:48 +0300
Message-ID: <20140825093648.GB5046@mwanda>
References: <20140819123655.GC12160@sucs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Jason Wang <jasowang@redhat.com>, Haiyang Zhang <haiyangz@microsoft.com>,
 linux-kernel@vger.kernel.org, Daniel Borkmann <dborkman@redhat.com>,
 netdev@vger.kernel.org, devel@linuxdriverproject.org,
 "David S. Miller" <davem@davemloft.net>
To: Sitsofe Wheeler <sitsofe@gmail.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <20140819123655.GC12160@sucs.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

The code here is:

drivers/hv/channel.c
   460          BUG_ON(ret != 0);
   461          t = wait_for_completion_timeout(&info->waitevent, 5*HZ);
   462          BUG_ON(t == 0);

So it calls BUG_ON() if the teardown takes more than 5 seconds.  It's
most likely that there is a race condition somewhere.  It's also
possible that it's just taking longer than 5 seconds for some odd
reason and the bug would go away if we raised it to 60 seconds.

BUG_ON() after 5 seconds seems like a very aggressive thing.

regards,
dan carpenter
