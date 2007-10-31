From: Gabriel C <nix.or.die@googlemail.com>
Subject: drivers/net/tlan question
Date: Wed, 31 Oct 2007 18:59:02 +0100
Message-ID: <4728C266.2010600@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, tlan-devel@lists.sourceforge.net,
	chessman@tux.org
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.188]:48916 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752719AbXJaR7H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2007 13:59:07 -0400
Received: by nf-out-0910.google.com with SMTP id g13so212014nfb
        for <netdev@vger.kernel.org>; Wed, 31 Oct 2007 10:59:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I noticed on current git the following warning with !CONFIG_PCI :

...

drivers/net/tlan.c: In function 'TLan_probe1':
drivers/net/tlan.c:682: warning: label 'err_out' defined but not used

...

I thought a simply #ifdef is missing but looking at TLan_probe1() I got confused about err_out_regions

...

#ifdef CONFIG_PCI
        if (pdev) {
                rc = pci_enable_device(pdev);
                if (rc)
                        return rc;

                rc = pci_request_regions(pdev, TLanSignature);
                if (rc) {
                        printk(KERN_ERR "TLAN: Could not reserve IO regions\n");
                        goto err_out;
                }
        }
#endif  /*  CONFIG_PCI  */

        dev = alloc_etherdev(sizeof(TLanPrivateInfo));
        if (dev == NULL) {
                printk(KERN_ERR "TLAN: Could not allocate memory for device.\n");
                rc = -ENOMEM;
                goto err_out_regions;
        }

...

...

err_out_regions:
#ifdef CONFIG_PCI
        if (pdev)
                pci_release_regions(pdev);
#endif
err_out:
        if (pdev)
                pci_disable_device(pdev);
        return rc;

...

It is possible 'dev' to be NULL with !CONFIG_PCI ? If is true then err_out_regions: does nothing ? 

Does this look right ?


Regards,

Gabriel 

 
