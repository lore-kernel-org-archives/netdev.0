From: Andre Tomt <andre@tomt.net>
Subject: 2.6.10 ipv6/8021q lockup on vconfig on interface removal
Date: Sun, 16 Jan 2005 07:30:25 +0100
Message-ID: <41EA0A01.2020707@tomt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I sent this initially about a week ago, but nobody have said anything, 
not even a confirmation that its beeing looked into, or about me beeing 
silly - highly unusual on netdev! So I'm reposting (with slight 
modifications), boo, shame on me. Just a bit worried it slipped through 
the cracks.



Hi!

Another "unregister_netdevice: waiting for eth0.1 to become free. Usage
count = 1" issue coming up.. Fun fun fun! And this one also seems to be
related to the ipv6 stack.

I can reproduce this reliably this by ifdown lo before ifdown'ing
eth0.1. That is, if lo goes down first, vconfig rem eth0.1 gets stuck
when run later. This only happens with ipv6.ko loaded. I havn't added
*any* ipv6 adresses to any interace, the only one are those the
ipv6-stack adds itself.

This is hitting us often on our routers, as we have ipv6.ko loaded, and
Debian runs ifdown -a (bring down all configured interfaces, starting
with lo unfortunatly) on shutdown and reboot. I've currently 
workarounded the problem by making sure ifdown -a is not run on reboot 
or shutdown, but this is, well, a workaround.

Bringing down non-vlan interfaces works just fine after killing lo. I 
have not attempted to *remove* them like vconfig does, though.

a backtrace from vconfing captured with sysrq-T (quickly typed off-screen):

shedule_timeout
process_timeout
netdev_wait_allrefs
netdev_wait_allrefs
netdev_run_todo
unregister_vlan_device [8021q]
vlan_ioctl_handler [8021q]
sock_ioctl
sys_ioctl
syscall_call

The lab machine is running with a minimalist config, no listeners
besides sshd, ipv6.ko and 8021q.ko loaded.
