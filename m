From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net-next,v2] hyperv: Increase the buffer length for
 netvsc_channel_cb()
Date: Thu, 14 Aug 2014 14:28:56 -0700 (PDT)
Message-ID: <20140814.142856.1220870703473741209.davem@redhat.com>
References: <1407953024-35191-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 driverdev-devel@linuxdriverproject.org, linux-kernel@vger.kernel.org
To: haiyangz@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1407953024-35191-1-git-send-email-haiyangz@microsoft.com>
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
Date: Wed, 13 Aug 2014 18:03:44 +0000

> When the buffer is too small for a packet from VMBus, a bigger buffer will be
> allocated in netvsc_channel_cb() and retry reading the packet from VMBus.
> Increasing this buffer size will reduce the retry overhead.
> 
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> Reviewed-by: Dexuan Cui <decui@microsoft.com>
...
> -	net_device = kzalloc(sizeof(struct netvsc_device), GFP_KERNEL);
> +	net_device = vzalloc(sizeof(*net_device));

This isn't what I suggested that you do.

I said that the buffer inside of netvsc_device should be made an
indirect pointer and thus allocated seperately.

Thus you're still kzalloc() net_device, but net_device->cb_buffer
becomes "unsigned char *" and another allocation is made for it.
