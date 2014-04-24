From: ratheesh kannoth <ratheesh.ksz@gmail.com>
Subject: performance decrease ?
Date: Thu, 24 Apr 2014 15:45:48 +0530
Message-ID: <CAGZFCEEYy9qULvzSr9JyBJtA6h+_NvL3gqxLF4dSy1yMupM2xQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>,
	Netfilter mailing list <netfilter@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

I did an experiment  and this experiment gave me an unexpected result
( for me). I would like to get any clue or hint on this.
[ ubuntu  kernel version  3.11 ]

i wrote an userpace program to create two tap devices( tap77 and tap88
) and will epoll on these fds. if a packet is received on  tap77 fd,
it will be read() and write to tap88 fd  and vice versa. Basically
this program will send pkts from tap88 to tap77 and vice versa.  when
i sent 10  icmp packets (using ping ); i got  rtt min/avg/max/mdev
=.825/1.006/2.052/.310 ms.


I modified  tun_net_xmit() function in tun.c and created another
driver and ran the above test.

   tun_net_xmit() {

          skb_orphan(skb);

         if( skb->dev == tap77_dev ) skb->dev= tap88_dev
         else if (skb->dev == tap88_dev ) skb->dev = tap77_dev;

         skb_reset_mac_header(skb);
         skb_reset_network_header(skb);
         skb_reset_transport_header(skb);

         netif_rx_ni(skb);
 }


i got rtt min/avg/max/mdev = .778/1.023/2.662/.549.


With the modified driver,  Although we avoided   2 packet copies and 2
system call, it did not result in  performance
improvement ( it did decrease by a small delta ).

Thanks,
Ratheesh

------------------------------------------------------------------------------
Start Your Social Network Today - Download eXo Platform
Build your Enterprise Intranet with eXo Platform Software
Java Based Open Source Intranet - Social, Extensible, Cloud Ready
Get Started Now And Turn Your Intranet Into A Collaboration Platform
http://p.sf.net/sfu/ExoPlatform
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
