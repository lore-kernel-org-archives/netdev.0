From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net v3.16]r8169: Remove unsupported command on pci express
Date: Fri, 11 Mar 2016 23:00:39 +0100
Message-ID: <20160311220038.GA7888@electric-eye.fr.zoreil.com>
References: <1457708793-1805-1-git-send-email-asd@marian1000.go.ro>
 <56E3182D.6050107@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Corcodel Marian <asd@marian1000.go.ro>, netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:40495 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932124AbcCKWAx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 17:00:53 -0500
Content-Disposition: inline
In-Reply-To: <56E3182D.6050107@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sergei Shtylyov <sergei.shtylyov@cogentembedded.com> :
[...]
> >@@ -7083,8 +7084,11 @@ rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
> >  	}
> >  	tp->mmio_addr = ioaddr;
> >
> >-	if (!pci_is_pcie(pdev))
> >+	if (!pci_is_pcie(pdev)) {
> >  		netif_info(tp, probe, dev, "not PCI Express\n");
> >+		tp->pcie = 0;
> >+	} else
> >+		tp->pcie = 1;
> 
>    Same question, you should assign true/false.

He should not bloat the private struct in the first place and the log
message adds no value but the change makes sense.

-- 
Ueimor
