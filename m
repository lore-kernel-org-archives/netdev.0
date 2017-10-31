From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 3/4] hv_netvsc: reset net_device_ctx->nvdev
 with rcu_assign_pointer()
Date: Tue, 31 Oct 2017 17:45:33 +0100
Message-ID: <20171031174533.6877e1a5@shemminger-XPS-13-9360>
References: <20171031134204.15287-1-vkuznets@redhat.com>
 <20171031134204.15287-4-vkuznets@redhat.com>
 <1509458998.3828.19.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <sthemmin@microsoft.com>, netdev@vger.kernel.org,
 Haiyang Zhang <haiyangz@microsoft.com>, linux-kernel@vger.kernel.org,
 devel@linuxdriverproject.org, Vitaly Kuznetsov <vkuznets@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1509458998.3828.19.camel@edumazet-glaptop3.roam.corp.google.com>
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

On Tue, 31 Oct 2017 07:09:58 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Tue, 2017-10-31 at 14:42 +0100, Vitaly Kuznetsov wrote:
> > RCU_INIT_POINTER() is not suitable here as it doesn't give us ordering
> > guarantees (see the comment in rcupdate.h). This is also not a hotpath.
> > 
> > Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
> > ---
> >  drivers/net/hyperv/netvsc.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
> > index bfc79698b8f4..12efb3e34775 100644
> > --- a/drivers/net/hyperv/netvsc.c
> > +++ b/drivers/net/hyperv/netvsc.c
> > @@ -560,7 +560,7 @@ void netvsc_device_remove(struct hv_device *device)
> >  
> >  	netvsc_revoke_buf(device, net_device);
> >  
> > -	RCU_INIT_POINTER(net_device_ctx->nvdev, NULL);
> > +	rcu_assign_pointer(net_device_ctx->nvdev, NULL);  
> 
> I see no point for this patch.
> 
> Setting a NULL pointer needs no barrier at all.

Agreed with Eric.
