From: Ben Greear <greearb@candelatech.com>
Subject: Pktgen receive hook in dev.c?
Date: Fri, 29 Apr 2005 16:30:12 -0700
Message-ID: <4272C384.50901@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I am curious if there is any interest in adding a hook in the netif_receive_skb
method to allow receiving (and consuming) pktgen packets.  This gives the ability
to get some good packet receive & latency stats using pktgen.

I asked this a year or so ago and was told no, but since then the netpoll and
TC_NCLS hooks have been added.... so maybe hooks are OK again?

The hook would look something like:

#if defined(CONFIG_NET_PKTGEN) || defined(CONFIG_NET_PKTGEN_MODULE)
         if ((skb->dev->priv_flags & IFF_PKTGEN_RCV) &&
             (handle_pktgen_rcv(skb) >= 0)) {
                 /* Pktgen may consume the packet, no need to send
                  * to further protocols.
                  */
                 goto out;
         }
#endif

         type = skb->protocol;
         list_for_each_entry_rcu(ptype, &ptype_base[ntohs(type)&15], list) {
....


Take it easy,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
