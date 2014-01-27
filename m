From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: hyperv: initialize link status correctly
Date: Mon, 27 Jan 2014 00:35:59 -0800 (PST)
Message-ID: <20140127.003559.2290408024387922847.davem@davemloft.net>
References: <1390807854-4469-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, haiyangz@microsoft.com,
 linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: jasowang@redhat.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1390807854-4469-1-git-send-email-jasowang@redhat.com>
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

From: Jason Wang <jasowang@redhat.com>
Date: Mon, 27 Jan 2014 15:30:54 +0800

> Call netif_carrier_on() after register_device(). Otherwise it won't work since
> the device was still in NETREG_UNINITIALIZED state.
> 
> Fixes a68f9614614749727286f675d15f1e09d13cb54a
> (hyperv: Fix race between probe and open calls)
> 
> Cc: Haiyang Zhang <haiyangz@microsoft.com>
> Cc: K. Y. Srinivasan <kys@microsoft.com>
> Reported-by: Di Nie <dnie@redhat.com>
> Tested-by: Di Nie <dnie@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

A device up can occur at the moment you call register_netdevice(),
therefore that up call can see the carrier as down and fail or
similar.  So you really cannot resolve the carrier to be on in this
way.
