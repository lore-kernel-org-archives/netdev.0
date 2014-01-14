From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] hyperv: Add support for physically
 discontinuous receive buffer
Date: Tue, 14 Jan 2014 14:31:33 -0800 (PST)
Message-ID: <20140114.143133.1863157816134006560.davem@davemloft.net>
References: <1389306287-20057-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 driverdev-devel@linuxdriverproject.org, linux-kernel@vger.kernel.org
To: haiyangz@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1389306287-20057-1-git-send-email-haiyangz@microsoft.com>
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

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Thu,  9 Jan 2014 14:24:47 -0800

> This will allow us to use bigger receive buffer, and prevent allocation failure
> due to fragmented memory.
> 
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>

Not until you start using paged SKBs in netvsc_recv_callback.

Whatever fragmention you think you're avoiding in the hyperv layer,
you're still going to get from the:

	skb = netdev_alloc_skb_ip_align(net, packet->total_data_buflen);

call there.

This change makes no sense in isolation, therefore I'm not applying it
until you also include the appropriate changes to avoid the same
exact fragmentation issue in netvsc_drv.c as stated above.
