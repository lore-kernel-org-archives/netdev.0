From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH net-next v1 2/2] bridge: export multicast
 database via netlink
Date: Sat, 01 Dec 2012 11:56:18 +0800
Message-ID: <1354334178.9680.7.camel@cr0>
References: <1354269514-1863-1-git-send-email-amwang@redhat.com>
	<1354269514-1863-2-git-send-email-amwang@redhat.com>
	<20121130112618.GF30697@casper.infradead.org>
	<1354287652.19865.10.camel@cr0>
	<20121130152733.GH30697@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20121130152733.GH30697@casper.infradead.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-11-30 at 15:27 +0000, Thomas Graf wrote:
> On 11/30/12 at 11:00pm, Cong Wang wrote:
> > I don't understand this. nla_put_flag() is used to put a flag (only one
> > bit set) into a netlink message, so why should we use it to put
> > p->port_no here? And why port_no 0 matters here?
> 
> nla_put_flag() will simply add a netlink attribute with no payload,
> i.e. just the header. Assuming that port_no == 0 is invalid the
> port_no can be used as attribute id as both are 16bit integers.
> 
> It will look like this:
> 
> MDBA_ROUTERS = {
>   {
>     .nla_len = 4,
>     .nla_type = <port_no_1>,
>   },
>   {
>     .nla_len = 4,
>     .nla_type = <port_no_2>,
>   }
>   [...]
> }
> 
> If you ever need to extend this you can just add payload to the
> per port attribute and nothing will break.

Never mind, I will use port->dev->ifindex instead of port->port_no. This
will also make the user-space easier.

> 
> > So I should use net->dev_base_seq + mdb->seq ?
> 
> No you can't, mdb->seq is not stable throughout a dump. What you
> can do is save mdb->seq in cb->args[] and in case you continue
> dumping from the same mdb in the next call to your dump function
> you check if it changed and bump cb->seq if it did to trigger an
> interrupt.

Ok, will do.

Thanks!
