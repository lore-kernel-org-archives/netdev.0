From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH/RFC] Let {ip,arp}tables "see" bridged VLAN tagged
 {I,AR}P packets
Date: Mon, 6 Oct 2003 13:19:16 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031006131916.6a7ba5c0.shemminger@osdl.org>
References: <200310062204.07230.bdschuym@pandora.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, bridge <bridge@osdl.org>,
        "David S.Miller" <davem@redhat.com>,
        Ben Greear <greearb@candelatech.com>, vlan@wanfear.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Bart De Schuymer <bdschuym@pandora.be>
In-Reply-To: <200310062204.07230.bdschuym@pandora.be>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 6 Oct 2003 22:04:07 +0200
Bart De Schuymer <bdschuym@pandora.be> wrote:

> Hi all,
> 
> The patch below does four trivial changes and one big change
> Trivial changes, these are all in br_netfilter.c:
> - check ar_pln==4 when giving bridged ARP packets to arptables
> - delete unnecessary if in br_nf_local_in
> - add more logging for the "Argh" message
> - add some brag-comments in the file head comment
> 
> Big change: let {ip,arp}tables see VLAN tagged {I,AR}P packets.
> This patch also makes an oops go away when locally generated packets
> are sent through something like br0.1000.
> 
> This is what the patch does:
> - add vlan_dev_hard_start_xmit_p, because br_netfilter.c needs to know
> the address of vlan_dev_hard_start_xmit(). When the local machine sends
> a packet through br0.1000, we need to allow filtering in LOCAL_OUT/FILTER
> on the bridge out port, so we need to be able to postpone the iptables
> filtering.

> Comments are welcome.
> If people could test this patch and give feedback, that would be great.
> 
> cheers,
> Bart


I can test the no VLAN case, but actual VLAN's are a little harder to setup.
How does this affect the ability to rmmod either vlan or bridge?
