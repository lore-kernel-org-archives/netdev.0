From: Giacomo <delleceste@gmail.com>
Subject: Get the IP address of an interface with a given name
Date: Mon, 19 Nov 2007 15:39:46 +0100
Message-ID: <885896af0711190639x5804d29eqdd6a6878a07b4f0a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.182]:58408 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751703AbXKSOjs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2007 09:39:48 -0500
Received: by py-out-1112.google.com with SMTP id u77so5817398pyb
        for <netdev@vger.kernel.org>; Mon, 19 Nov 2007 06:39:48 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 /* returns in *addr the internet address having the name ifname */
 int get_ifaddr_by_name(const char *ifname, __u32 * addr)
 {
        struct net_device *pnet_device;
        struct in_device *pin_device;
        struct in_ifaddr* inet_ifaddr;

        read_lock_bh(&dev_base_lock);
 #if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,22)
        pnet_device = dev_base;
 #else
        pnet_device = first_net_device();
 #endif
        while (pnet_device != NULL)
        {
                if ((netif_running(pnet_device))
                                && (pnet_device->ip_ptr != NULL)
                                && (strcmp(pnet_device->name, ifname) == 0))
                {
                        pin_device =
                                (struct in_device *) pnet_device->ip_ptr;
                        inet_ifaddr = pin_device->ifa_list;
                        if(inet_ifaddr == NULL)
                        {
                                printk("ifa_list is null!\n");
                                break;
                        }
                        /* ifa_local: ifa_address is the remote point in ppp */
                        *addr = (inet_ifaddr->ifa_local);
                          read_unlock_bh(&dev_base_lock);
                        return 1;
                }
 #if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,22)
                pnet_device = pnet_device->next;
 #else
                pnet_device = next_net_device(pnet_device);
 #endif

        }

        read_unlock_bh(&dev_base_lock);
        return -1;              /* address not found! */
 }


-- 
Giacomo S.
http://www.giacomos.it

- - - - - - - - - - - - - - - - - - - - - -

IPFIREwall (http://www.giacomos.it/ipfire) viene presentato
all'Universita` degli Studi di Udine, il 28 ottobre, in occasione del
Linux Day 2006:
http://iglu.cc.uniud.it/linuxday

- - - - - - - - - - - - - - - - - - - - - -

 . ''  `.
:   :'    :
 `.  ` '
    `- Debian GNU/Linux -- The power of freedom
        http://www.debian.org
