From: Shmulik Hen <shmulik.hen@intel.com>
Subject: Re: Does the bonding driver honour dev->features of slave devices
Date: Thu, 11 Sep 2003 16:15:17 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309111615.17515.shmulik.hen@intel.com>
Reply-To: shmulik.hen@intel.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Subject: Re: Does the bonding driver honour dev->features of slave 
devices
Date: Thu, 11 Sep 2003 10:44:46 +0300
From: Shmulik Hen <shmulik.hen@intel.com>
To: "Tomar, Nagendra" <nagendra_tomar@adaptec.com>, 
<linux-net@vger.kernel.org>

On Wednesday 10 September 2003 09:25 pm, Tomar, Nagendra wrote:
> Hello All,
>           I am going throgh the "Link Aggregation" module in Linux
> (bonding.c). The code seems to suggest that the dev->features of
> slave devices is simply ignored while bundling into the master
> device. Suppose I have two Intel epro1000 cards that can support
> TCP Segmentation Offload. Now if I bond these two slave cards into
> a new master card, the new bonding device that is the master device
> will be used in the routing table. When a TCP connection is
> established sk->route_caps is assigned from the dev->features of
> the assigned outgoing device. If the outgoing device is the bonding
> device then the dev->features won't have NETIF_F_TSO as the feature
> and hence upper layers will believe that the outgoing device cannot
> do TSO.
> I believe that at best we can take an OR of the dev->features of
> all the slave devices and assign it to the dev->features of the
> bonding device. This way we are sure that we are taking the Least
> Common Denominator while deciding the features for the master
> device.
>
>
> Thanx,
> tomar

That's one of the new things we've started working on. There are
multiple things exported by dev->features that need to be taken care
of, but since they belong to different categories, they'll have to be
handled separately. For example, 8021q VLAN hardware offloading can
be exported through the master device, but then the module will need
to handle tagged packets differently for "strong" or "weak" slaves.
Zero copy and CSUM offloading is also a possibility we're adding and
it should be even easier since the packets go again through the
slave's device queue and are linearized and summed automatically if
the slave is not capable. TSO is kind of new for us, but it is
definitely something worth our attention. We'll first need to study
what is the meaning of TSO and how it is handled throughout the stack
and then see what can be done.

-- 
| Shmulik Hen   Advanced Network Services  |
| Israel Design Center, Jerusalem          |
| LAN Access Division, Platform Networking |
| Intel Communications Group, Intel corp.  |
