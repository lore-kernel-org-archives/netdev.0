From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net-next] hv_netvsc: Add support to set MTU reservation
 from guest side
Date: Mon, 6 Jul 2015 19:32:20 +0000
Message-ID: <BN1PR0301MB077052B05F1CCC4EF7697DF3CA930@BN1PR0301MB0770.namprd03.prod.outlook.com>
References: <1435868255-10865-1-git-send-email-haiyangz@microsoft.com>
 <20150703112847.GA28762@mwanda>
 <20150703.091729.499431982657478377.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "olaf@aepfle.de" <olaf@aepfle.de>, "driverdev-devel@linuxdriverproject.org"
 <driverdev-devel@linuxdriverproject.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>, "dan.carpenter@oracle.com"
 <dan.carpenter@oracle.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20150703.091729.499431982657478377.davem@davemloft.net>
Content-Language: en-US
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



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Friday, July 3, 2015 12:17 PM
> To: dan.carpenter@oracle.com
> Cc: Haiyang Zhang; netdev@vger.kernel.org; olaf@aepfle.de;
> jasowang@redhat.com; driverdev-devel@linuxdriverproject.org; linux-
> kernel@vger.kernel.org
> Subject: Re: [PATCH net-next] hv_netvsc: Add support to set MTU
> reservation from guest side
> 
> From: Dan Carpenter <dan.carpenter@oracle.com>
> Date: Fri, 3 Jul 2015 14:28:47 +0300
> 
> > On Thu, Jul 02, 2015 at 01:17:35PM -0700, Haiyang Zhang wrote:
> >> When packet encapsulation is in use, the MTU needs to be reduced for
> >> headroom reservation.
> >> The existing code takes the updated MTU value only from the host side.
> >> But vSwitch extensions, such as Open vSwitch, require the flexibility
> >> to change the MTU to different values from within a guest during the
> >> lifecycle of a vNIC, when the encapsulation protocol is changed. The
> >> patch supports this kind of MTU changes.
> >>
> >> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> >> Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
> >> ---
> >>  drivers/net/hyperv/netvsc_drv.c   |    3 +--
> >>  drivers/net/hyperv/rndis_filter.c |    2 +-
> >>  2 files changed, 2 insertions(+), 3 deletions(-)
> >>
> >> diff --git a/drivers/net/hyperv/netvsc_drv.c
> b/drivers/net/hyperv/netvsc_drv.c
> >> index 358475e..68e7ece 100644
> >> --- a/drivers/net/hyperv/netvsc_drv.c
> >> +++ b/drivers/net/hyperv/netvsc_drv.c
> >> @@ -743,8 +743,7 @@ static int netvsc_change_mtu(struct net_device
> *ndev, int mtu)
> >>  	if (nvdev->nvsp_version >= NVSP_PROTOCOL_VERSION_2)
> >>  		limit = NETVSC_MTU - ETH_HLEN;
> >>
> >> -	/* Hyper-V hosts don't support MTU < ETH_DATA_LEN (1500) */
> >> -	if (mtu < ETH_DATA_LEN || mtu > limit)
> >> +	if (mtu < 68 || mtu > limit)
> >
> > How did you calculate 68?  Avoid magic numbers like this, make it a
> > define.
> 
> Agreed.

The number 68 is same as the common code in eth_change_mtu(). I think it
came from the protocol requirement:
https://en.wikipedia.org/wiki/Maximum_transmission_unit

Sure, I will put the number in a define, and resubmit the patch.

Thanks,
- Haiyang
