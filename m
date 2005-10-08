From: Olaf Hering <olh@suse.de>
Subject: pcnet32 does not use the PROM address on powerpc
Date: Sat, 8 Oct 2005 12:47:25 +0200
Message-ID: <20051008104725.GA10248@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linuxppc64-dev-bounces@ozlabs.org>
To: netdev@vger.kernel.org, linuxppc64-dev@ozlabs.org
Content-Disposition: inline
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc64-dev>
List-Post: <mailto:linuxppc64-dev@ozlabs.org>
List-Help: <mailto:linuxppc64-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc64-dev-bounces@ozlabs.org
Errors-To: linuxppc64-dev-bounces@ozlabs.org
List-Id: netdev.vger.kernel.org


Does anyone remember why ppc is handled special in pcnet32_probe1()?
It as added to Linus tree around 2.6.14, I dont find relevant patches in
our bugzilla. It was likely added during early ppc64 bringup.

google doesnt know the patch submitter, perhaps jgarzik has some old
records from around 2000/2001?


I have a 44p 270, which gets all 0xFF as MAC address if I power if off
and on again. Further reboots do not fix it.
But it does get the correct one if I boot into SMS and do a netboot,
further reboots will always get the correct MAC address

I think these 0xFF happen also on other systems, I have seen them on B50
as well. We should just remove the #ifdef.


....
    if (memcmp(promaddr, dev->dev_addr, 6)
        || !is_valid_ether_addr(dev->dev_addr)) {
#ifndef __powerpc__
        if (is_valid_ether_addr(promaddr)) {
#else   
        if (!is_valid_ether_addr(dev->dev_addr)
            && is_valid_ether_addr(promaddr)) {
#endif
            if (pcnet32_debug & NETIF_MSG_PROBE) {
                printk(" warning: CSR address invalid,\n");
                printk(KERN_INFO "    using instead PROM address of");
            }
            memcpy(dev->dev_addr, promaddr, 6);
        }
    }
....


-- 
short story of a lazy sysadmin:
 alias appserv=wotan
