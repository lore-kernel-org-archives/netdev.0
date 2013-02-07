From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 2/2] qlcnic: set gso_type
Date: Thu, 7 Feb 2013 10:16:35 +0200
Message-ID: <20130207081634.GB9126@redhat.com>
References: <cover.1360191528.git.mst@redhat.com>
	<f262d9330d22447ed8fd487ad7b28d668efbf333.1360191528.git.mst@redhat.com>
	<1360207237.28557.48.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Sony Chacko <sony.chacko@qlogic.com>, linux-driver@qlogic.com,
	bhutchings@solarflare.com, linux-kernel@vger.kernel.org,
	Jacob Keller <jacob.e.keller@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <1360207237.28557.48.camel@edumazet-glaptop>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, Feb 06, 2013 at 07:20:37PM -0800, Eric Dumazet wrote:
> On Thu, 2013-02-07 at 01:02 +0200, Michael S. Tsirkin wrote:
> > qlcnic set gso_size but not gso type. This leads to crashes
> > in macvtap.
> > 
> > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> > ---
> > This one I only compiled - don't have qlogic hardware.
> > 
> >  drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c | 7 ++++++-
> >  1 file changed, 6 insertions(+), 1 deletion(-)
> > 
> > diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
> > index bb4311e..370049c 100644
> > --- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
> > +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
> > @@ -1043,8 +1043,13 @@ qlcnic_process_lro(struct qlcnic_adapter *adapter,
> >  	th->seq = htonl(seq_number);
> >  	length = skb->len;
> >  
> > -	if (adapter->flags & QLCNIC_FW_LRO_MSS_CAP)
> > +	if (adapter->flags & QLCNIC_FW_LRO_MSS_CAP) {
> >  		skb_shinfo(skb)->gso_size = qlcnic_get_lro_sts_mss(sts_data1);
> > +		if (skb->protocol == ETH_P_IPV6)
> 
> Are you sure its not skb->protocol == htons(ETH_P_IPV6) ?

Um, so it is. It just happens to work correctly for ipv4 :)
I'll respin.

> > +			skb_shinfo(skb)->gso_type = SKB_GSO_TCPV6;
> > +		else
> > +			skb_shinfo(skb)->gso_type = SKB_GSO_TCPV4;
> > +	}
> >  
> >  	if (vid != 0xffff)
> >  		__vlan_hwaccel_put_tag(skb, vid);
> 

------------------------------------------------------------------------------
Free Next-Gen Firewall Hardware Offer
Buy your Sophos next-gen firewall before the end March 2013 
and get the hardware for free! Learn more.
http://p.sf.net/sfu/sophos-d2d-feb
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
