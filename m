From: Ben Greear <greearb@candelatech.com>
Subject: routing bug report for 2.4
Date: Fri, 27 Jun 2003 16:00:37 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EFCCC95.3000709@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

(This has been discussed with Alexey, but sending to the list for
general consumption).

Here is how to reproduce this:

ifconfig eth1 192.1.1.2 netmask 255.255.255.0
ifconfig eth2 192.1.2.2 netmask 255.255.255.0


Set up policy based routing with the 'ip' tool to make packets with
source-address of each interface to use the gateway for that interface.
   Set gateway for eth1 to be 192.1.1.1
   Set gateway for eth2 to be 192.1.2.1


Now, use ping to try to send pkts from one interface to the other:

ping -I 192.1.1.2 192.1.2.2

You will see arps on eth1 for 192.1.2.2, whereas you should see packets
being sent to the default gateway for eth1.

If you modify the ping source to BINDTODEVICE eth1, then it will send
correctly.  I am under the impression that you should not have to specifically
BINDTODEVICE in this case since the policy based routing should take care of
routing things correctly.  Or, maybe, the real bug is in ping in that it did
not BINDTODEVICE?

Also, ping -I eth1 192.1.2.2 will fail to route externally.  That may
just be a feature of ping:  I'm unsure what the subtle difference is *supposed*
to be between using -I eth1 and -I 1.2.3.4


Thanks,
Ben



-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
