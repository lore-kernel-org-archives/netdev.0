From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] hv_netvsc: rework link status change handling
Date: Tue, 01 Dec 2015 15:03:59 -0500 (EST)
Message-ID: <20151201.150359.1001330212099906860.davem@davemloft.net>
References: <1448620795-8572-1-git-send-email-vkuznets@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, haiyangz@microsoft.com,
 linux-kernel@vger.kernel.org, devel@linuxdriverproject.org
To: vkuznets@redhat.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1448620795-8572-1-git-send-email-vkuznets@redhat.com>
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
Date: Fri, 27 Nov 2015 11:39:55 +0100

> There are several issues in hv_netvsc driver with regards to link status
> change handling:
> - RNDIS_STATUS_NETWORK_CHANGE results in calling userspace helper doing
>   '/etc/init.d/network restart' and this is inappropriate and broken for
>   many reasons.
> - link_watch infrastructure only sends one notification per second and
>   in case of e.g. paired disconnect/connect events we get only one
>   notification with last status. This makes it impossible to handle such
>   situations in userspace.
> 
> Redo link status changes handling in the following way:
> - Create a list of reconfig events in network device context.
> - On a reconfig event add it to the list of events and schedule
>   netvsc_link_change().
> - In netvsc_link_change() ensure 2-second delay between link status
>   changes.
> - Handle RNDIS_STATUS_NETWORK_CHANGE as a paired disconnect/connect event.
> 
> Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>

Applied, thank you.
