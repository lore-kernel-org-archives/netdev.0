From: Andre Tomt <andre@tomt.net>
Subject: cpu optimalization settings in 2.6 and routing
Date: Sat, 29 May 2004 07:25:32 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40B81ECC.5060607@tomt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi!

I'm currently planning to do a sitewide deployment of Linux 2.6, and I'm 
taking the opportunity to clean up the kernel build setup we use at the 
same time.

The goal is to get the number of kernel images down to a minimum. 
Question is: Does the cpu optimalization settings in kernel affect 
routing cache, interrupt overhead and conntracking? How much?


Our 2.4 setup currently goes like this:

Three "base configurations" - server, router, natrouter. Everything we 
use as modules (where possible), using initrd to get boot-critical 
drivers up, no kmod.

with the server profile beeing the base;
router    = server - highmem
natrouter = router + nat + packet mangling + advanced routing (policy 
routing)

Reasoning behing this is that NAT makes the conntrack structures in 
memory bloat a lot per tracked connection. Policy routing I think also 
bloats the routing structures. All this can be critical on routers and 
servers that run their own local firewalling, especially under attack.

from theese three configurations, a kernel-image package for each of the 
cpu types of "i586", "p3", "k7", "p4" and "p4smp" is generated.

Current battle plan is to cut the base configurations down to "standard" 
and "natrouter". Ordinary routers have to do with the standard profile, 
as we expect to gain more just by running 2.6 than what we would have 
lost with adding highmem. KISS beeing the main driving factor.

So far, so good.

Then to drop the per cpu type images. The plan here is to just have 
CONFIG_M586 + CONFIG_X86_GENERIC. One with SMP/HT, one without. ie 
"i586" and "i586smp".

For servers, thats probably just fine.  They spend most of their time in 
userspace anyway. And they gain on things like NPTL. But then there is 
the routers. They spend 99.9% of their time in kernel space.
