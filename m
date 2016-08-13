From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/4] hv_netvsc: reset vf_inject on VF removal
Date: Fri, 12 Aug 2016 20:40:48 -0700 (PDT)
Message-ID: <20160812.204048.1773150628029363073.davem@davemloft.net>
References: <1470913137-29167-1-git-send-email-vkuznets@redhat.com>
 <1470913137-29167-3-git-send-email-vkuznets@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, haiyangz@microsoft.com,
 linux-kernel@vger.kernel.org, devel@linuxdriverproject.org
To: vkuznets@redhat.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1470913137-29167-3-git-send-email-vkuznets@redhat.com>
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
Date: Thu, 11 Aug 2016 12:58:55 +0200

> We reset vf_inject on VF going down (netvsc_vf_down()) but we don't on
> VF removal (netvsc_unregister_vf()) so vf_inject stays 'true' while
> vf_netdev is already NULL and we're trying to inject packets into NULL
> net device in netvsc_recv_callback() causing kernel to crash.
> 
> Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>

You can't create a blocking operation problem knowingly in this
patch just because you fix it in patch #4.

You must order your patches such that the driver does not regress
at any intermediate stage of your patch series.
