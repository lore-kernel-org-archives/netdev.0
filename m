From: Bart De Schuymer <bdschuym@pandora.be>
Subject: Re: [PATCH/RFC] Let {ip,arp}tables "see" bridged VLAN tagged
	{I,AR}P packets
Date: Mon, 6 Oct 2003 22:55:38 +0200
Sender: vlan-bounces@wanfear.com
Message-ID: <200310062255.38789.bdschuym@pandora.be>
References: <200310062204.07230.bdschuym@pandora.be>
	<20031006131916.6a7ba5c0.shemminger@osdl.org>
Reply-To: "Linux 802.1Q VLAN" <vlan@wanfear.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S.Miller" <davem@redhat.com>
Return-path: <vlan-bounces@wanfear.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20031006131916.6a7ba5c0.shemminger@osdl.org>
Content-Disposition: inline
cc: netdev@oss.sgi.com
cc: Ben Greear <greearb@candelatech.com>
cc: bridge <bridge@osdl.org>
cc: vlan@wanfear.com
List-Unsubscribe: <http://www.WANfear.com/mailman/listinfo/vlan>,
	<mailto:vlan-request@wanfear.com?subject=unsubscribe>
List-Archive: <http://ns1.wanfear.com/pipermail/vlan>
List-Post: <mailto:vlan@wanfear.com>
List-Help: <mailto:vlan-request@wanfear.com?subject=help>
List-Subscribe: <http://www.WANfear.com/mailman/listinfo/vlan>,
	<mailto:vlan-request@wanfear.com?subject=subscribe>
Errors-To: vlan-bounces@wanfear.com
List-Id: netdev.vger.kernel.org

On Monday 06 October 2003 22:19, Stephen Hemminger wrote:
> I can test the no VLAN case, but actual VLAN's are a little harder to
> setup.

Setting up vlan's is easy:
brctl addbr br0
brctl addif br0 eth0
ifconfig br0 $address
vconfig add br0 1000
ifconfig br0.1000 $address

> How does this affect the ability to rmmod either vlan or bridge?

Well, when br0.1000 exists and you then rmmod the bridge, it doesn't work. The 
way to do it is rmmod 8021q;rmmod bridge. I came across this issue, but I 
assumed it was not my fault. I thought the problem would exist without my 
code too, but I'm not sure if I checked. What also doesn't work is rmmod 
bridge followed by rmmod 8021q on a different console. I now just realize 
this is probably because the bridge depends on 8021q and we thus get a 
deadlock.
I think the right solution to this problem is, when rmmod bridge happens, it 
removes any tagged bridge devices first.

cheers,
Bart

_______________________________________________
VLAN mailing list  -  VLAN@wanfear.com
http://www.WANfear.com/mailman/listinfo/vlan
VLAN Page:  http://scry.wanfear.com/~greear/vlan.html
