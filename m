From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Subject: Re: [09/38] xen: netfront: explicitly generate
 arp_notify event after migration.
Date: Tue, 10 Aug 2010 14:07:27 +0100
Message-ID: <1281445647.24292.3897.camel@zakaz.uk.xensource.com>
References: <20100806183200.858950407@clark.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jeremy Fitzhardinge <jeremy@goop.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"stable@kernel.org" <stable@kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
	"stable-review@kernel.org" <stable-review@kernel.org>,
	"alan@lxorguk.ukuu.org.uk" <alan@lxorguk.ukuu.org.uk>
To: Greg KH <gregkh@suse.de>
Return-path: <xen-devel-bounces@lists.xensource.com>
In-Reply-To: <20100806183200.858950407@clark.site>
List-Unsubscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

Hi Greg,

Looks like I forgot to request this for 2.6.32 too, could you queue it
up there as well?

It depends on the previous patch in this series (arp_notify: allow
drivers to explicitly request a notification event.).

Thanks,
Ian.

On Fri, 2010-08-06 at 19:30 +0100, Greg KH wrote:
> 2.6.35-stable review patch.  If anyone has any objections, please let us know.
> 
> ------------------
> 
> From: Ian Campbell <Ian.Campbell@citrix.com>
> 
> commit 592970675c9522bde588b945388c7995c8b51328 upstream.
> 
> Use newly introduced netif_notify_peers() method to ensure a gratuitous ARP is
> generated after a migration.
> 
> Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
> Cc: Stephen Hemminger <shemminger@linux-foundation.org>
> Cc: Jeremy Fitzhardinge <jeremy@goop.org>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: netdev@vger.kernel.org
> Cc: xen-devel@lists.xensource.com
> Signed-off-by: David S. Miller <davem@davemloft.net>
> Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>
> 
> ---
>  drivers/net/xen-netfront.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> --- a/drivers/net/xen-netfront.c
> +++ b/drivers/net/xen-netfront.c
> @@ -1621,6 +1621,7 @@ static void backend_changed(struct xenbu
>  		if (xennet_connect(netdev) != 0)
>  			break;
>  		xenbus_switch_state(dev, XenbusStateConnected);
> +		netif_notify_peers(netdev);
>  		break;
>  
>  	case XenbusStateClosing:
> 
> 
