From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] hv_netvsc: fix a race between netvsc_send()
 and netvsc_init_buf()
Date: Fri, 21 Oct 2016 11:28:01 -0400 (EDT)
Message-ID: <20161021.112801.585243295635293094.davem@davemloft.net>
References: <1476885181-3456-1-git-send-email-vkuznets@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: sthemmin@microsoft.com, netdev@vger.kernel.org, haiyangz@microsoft.com,
 linux-kernel@vger.kernel.org, devel@linuxdriverproject.org
To: vkuznets@redhat.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1476885181-3456-1-git-send-email-vkuznets@redhat.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

From: Vitaly Kuznetsov <vkuznets@redhat.com>
Date: Wed, 19 Oct 2016 15:53:01 +0200

> Fix in commit 880988348270 ("hv_netvsc: set nvdev link after populating
> chn_table") turns out to be incomplete. A crash in
> netvsc_get_next_send_section() is observed on mtu change when the device
> is under load. The race I identified is: if we get to netvsc_send() after
> we set net_device_ctx->nvdev link in netvsc_device_add() but before we
> finish netvsc_connect_vsp()->netvsc_init_buf() send_section_map is not
> allocated and we crash. Unfortunately we can't set net_device_ctx->nvdev
> link after the netvsc_init_buf() call as during the negotiation we need
> to receive packets and on the receive path we check for it. It would
> probably be possible to split nvdev into a pair of nvdev_in and nvdev_out
> links and check them accordingly in get_outbound_net_device()/
> get_inbound_net_device() but this looks like an overkill.
> 
> Check that send_section_map is allocated in netvsc_send().
> 
> Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>

Applied, thanks.
