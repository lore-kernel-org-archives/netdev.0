From: Ben Greear <greearb@candelatech.com>
Subject: MAC-VLANS
Date: Tue, 05 Aug 2003 17:33:03 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F304CBF.6050902@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In order to get MAC-VLANs to work, the only way I can see to make
it happen is to put a hook into dev.c in the:
int netif_receive_skb(struct sk_buff *skb)
method.

The hook looks like this, and immediately follows the
bridging code hook in the same method:


#if defined(CONFIG_MACVLAN) || defined(CONFIG_MACVLAN_MODULE)
	if (skb->dev->macvlan_priv != NULL &&
	    macvlan_handle_frame_hook != NULL) {
                 if (handle_macvlan(skb) >= 0) {
                         /* consumed by mac-vlan...it would have been
                          * re-sent to this method with a different
                          * device...
                          */
                         return 0;
                 }
                 else {
                         /* Let it fall through and be processed normally */
                 }
	}
#endif

So, the question is: Will this feature be allowed to go in since it
needs this hook, regardless of other issues?  If it's possible, I'll
break out the rest of the patch for inspection...

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
