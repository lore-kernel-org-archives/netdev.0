From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [ofa-general] [PATCH 2.6.25] RDMA/cxgb3: Fail loopback
	connections.
Date: Tue, 12 Feb 2008 19:41:53 -0600
Message-ID: <47B24AE1.7040709@opengridcomputing.com>
References: <20080212220929.24442.76874.stgit@dell3.ogc.int>
	<adafxvxvgz3.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <adafxvxvgz3.fsf@cisco.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

Roland Dreier wrote:
> applied, although:
> 
>  > +static void is_loopback_dst(struct iw_cm_id *cm_id)
>  > +{
>  > +	struct net_device *dev;
>  > +	
>  > +	dev = ip_dev_find(&init_net, cm_id->remote_addr.sin_addr.s_addr);
>  > +	if (!dev)
>  > +		return 0;
>  > +	dev_put(dev);
>  > +	return 1;
>  > +}
> 
> is there any way this could trigger when it should, like if I'm trying
> to make a connection from one local device to a different local device
> (which should work fine)?
> 

As far as I can tell, if the app does a rdma_resolve_addr() on the dst 
addr (which is a local address), then the routing lookup will find the 
local interface with that dst addr, and that device will be used for the 
connect.  IE src and dst devices are the same.

Maybe if the app does an explicit bind to the addr on one device, then 
connects to the addr on the other device.  But that's not gonna work 
either, I think.  I still think it will resolve to one device and that 
device cannot do loopback...


Steve.
