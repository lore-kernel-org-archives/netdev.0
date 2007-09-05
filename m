From: Steve Wise <swise@opengridcomputing.com>
Subject: [ofa-general] Re: [PATCH RFC] iw_cxgb3: Support "iwarp-only"
 interfaces to avoid 4-tuple conflicts with the host stack.
Date: Wed, 05 Sep 2007 10:40:29 -0500
Message-ID: <46DECDED.90903@opengridcomputing.com>
References: <1187905185.5547.13.camel@stevo-desktop>	<adaveawwcpz.fsf@cisco.com>
	<46DD762F.80904@opengridcomputing.com> <ada642puonr.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ewg@lists.openfabrics.org,
	general@lists.openfabrics.org, linux-kernel@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <ada642puonr.fsf@cisco.com>
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
>  > > What's wrong with my suggestion of having the iwarp driver create an
>  > > "iwX" interface to go with the normal "ethX" interface?  It seems
>  > > simpler to me, and there's a somewhat similar precedent with how
>  > > mac80211 devices create both wlan0 and wmaster0 interfaces.
>  > >  - R.
>  > 
>  > It seemed much more painful for me to implement. :-)
>  > 
>  > I'll look into this, but I think for this to be done, the changes must
>  > be in the cxgb3 driver, not the rdma driver, because the guts of the
>  > netdev struct are all private to cxgb3.  Remember that this interface
>  > needs to still do non TCP traffic (like ARP and UDP)...
>  > 
>  > Maybe you have something in mind here that I'm not thinking about?
> 
> No, I was just spouting off.
>

At least someone is looking at my patch. ;-)

> But the whole "create a magic alias" seems kind of unfriendly to the
> user.  Maybe as you said, the cxgb3 net driver could create the alias
> for the iw_cxgb3 driver?

I agree that it is not very user friendly.

My current patch just utilizes the IP address alias logic in the IP 
stack.  So when you do 'ifconfig ethxx:blah ipaddr up' it creates a 
struct in_ifaddr which contains a ptr to the real struct net_device that 
services this alias.  However, from what I can tell, I cannot just 
create one of these without binding an address.  So the driver cannot 
create the alias interface until it knows the ipaddr/netmask/etc.  IE: 
if you say 'ifconfig ethxx:blah up' it fails...  You must supply an 
address to get one of these created.

To have the cxgb3 driver create something like 'iw0', I think it would 
need to create a full net_device struct.  This makes the change much 
more complex.  But perhaps its the right thing to do...

Steve.
