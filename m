From: "Narik Alatees" <yedok@hotmail.com>
Subject: Suggestion to Improve delivery to local destinations
Date: Wed, 20 Aug 2003 08:03:58 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <BAY7-F102JeALhPxXuu00024c5a@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Cc: kuznet@ms2.inr.ac.ru, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-net@vger.kernel.org, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Currently ip_route_output_slow() sets rth->u.dst.output = ip_output; And 
then there is this line in the same function:

if (flags & RTCF_LOCAL) {
                rth->u.dst.input = ip_local_deliver;
                rth->rt_spec_dst = fl.fl4_dst;
}

Basically what this means is that when the user calls skb->dst->output(), 
neighbour resolution would be implicitly performed. And at the time of 
actually sending an ARP request for link layer address the transmission is 
bypassed (due to the check in neigh_event_send()) and a dummy neighbour 
entry for the loopback device is constructured.

I propose that in the above code fragment rth->u.dst.output be changed to 
ip_dev_loopback_xmit() (much like what happens inside of ip_mc_output()). I 
think this would _significantly_ improve performance in the 
delivery-to-local-destination case. What do you think?

tx
yedok

_________________________________________________________________
<b>Get MSN 8</b> and help protect your children with advanced parental 
controls.  http://join.msn.com/?page=features/parental
