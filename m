From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 1/2] netvsc: reference counting fix
Date: Sun, 14 Aug 2016 21:31:33 -0700 (PDT)
Message-ID: <20160814.213133.1692896664092434326.davem@davemloft.net>
References: <1470913137-29167-1-git-send-email-vkuznets@redhat.com>
 <1470913137-29167-3-git-send-email-vkuznets@redhat.com>
 <20160813113559.617b7c55@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, haiyangz@microsoft.com,
 linux-kernel@vger.kernel.org, devel@linuxdriverproject.org
To: stephen@networkplumber.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20160813113559.617b7c55@xeon-e3>
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

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Sat, 13 Aug 2016 11:35:59 -0700

> This is how I think it should be fixed, but not tested yet.
> 
> Subjec: netvsc: use device not module reference counts
> 
> Fix how the cross-device reference counting is handled.  When VF is
> associated with the synthetic interface, the VF driver module should
> still be able to be unloaded.  The module unload code will callback
> with NETDEV_UNREGISTER event which breaks the connection safely.
> (Fixes 9f4b5ba5db4 hv_netvsc: Implement support for VF drivers on Hyper-V)
> 
> Signed-off-by: Stephen Hemminger <sthemmin@linuxonhyperv.com>

This might not work.

It is assumed that when a netdev unregister happens, it may be done so
at any point in time.

Therefore that NETDEV_UNREGISTER event must eliminate any and all
references to a given netdev.  And that works perfectly fine right now
with all existing subsystems that take references to netdevs.

You'll have to add something so that a NETDEV_UNREGISTER event tears
this VF down and thus releases it's reference to the synthetic device.
