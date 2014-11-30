From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH 1/1] net-PA Semi: Deletion of unnecessary checks before
 the function call "pci_dev_put"
Date: Sun, 30 Nov 2014 18:45:03 +0100
Message-ID: <547B579F.10709@gmx.de>
References: <5307CAA2.8060406@users.sourceforge.net> <alpine.DEB.2.02.1402212321410.2043@localhost6.localdomain6> <530A086E.8010901@users.sourceforge.net> <alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6> <530A72AA.3000601@users.sourceforge.net> <alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6> <530B5FB6.6010207@users.sourceforge.net> <alpine.DEB.2.10.1402241710370.2074@hadrien> <530C5E18.1020800@users.sourceforge.net> <alpine.DEB.2.10.1402251014170.2080@hadrien> <530CD2C4.4050903@users.sourceforge.net> <alpine.DEB.2.10.1402251840450.7035@hadrien> <530CF8FF.8080600@users.sourceforge.net> <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6> <530DD06F.4090703@users.sourceforge.net> <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6> <5317A59D.4@users.so
 urceforge.net> <547A09B1.9090102@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: SF Markus Elfring <elfring@users.sourceforge.net>,
	Olof Johansson <olof@lixom.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <547A09B1.9090102@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 29.11.2014 19:00, SF Markus Elfring wrote:

>  out:
> -	if (mac->iob_pdev)
> -		pci_dev_put(mac->iob_pdev);
> -	if (mac->dma_pdev)
> -		pci_dev_put(mac->dma_pdev);
> +	pci_dev_put(mac->iob_pdev);
> +	pci_dev_put(mac->dma_pdev);
>  
>  	free_netdev(dev);
>  out_disable_device:
> 

Hi,

I know there has been some criticism about those kind of "code
improvements" already but i would like to point out just one more thing:

Some of those NULL pointer checks on input parameters may have been
added subsequently to functions. So there may be older kernel versions
out there in which those checks dont exists in some cases. If some of
the now "cleaned up" code is backported to such a kernel chances are
good that those missing checks are overseen. And then neither caller nor
callee is doing the NULL pointer check.

Quite frankly i would vote for the opposite approach: Never rely on the
callee do to checks for NULL and do it always in the caller. An
exception could be for calls on a fast path. But most of those checks
are done on error paths anyway.

Just my 2 cents.

Regards,
Lino
