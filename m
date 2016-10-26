From: Baoquan He <bhe@redhat.com>
Subject: Re: [bnx2] [Regression 4.8] Driver loading fails without firmware
Date: Wed, 26 Oct 2016 20:00:21 +0800
Message-ID: <20161026120021.GA4402@x1>
References: <244cb42b-0fce-fe41-7b7c-babb51411e8c@molgen.mpg.de>
 <b0675854-41f9-e7b6-4ad0-85ff59b98977@molgen.mpg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Sony Chacko <sony.chacko@qlogic.com>,
        Dept-HSGLinuxNICDev@qlogic.com, netdev@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>
To: Paul Menzel <pmenzel@molgen.mpg.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39920 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932090AbcJZMA0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Oct 2016 08:00:26 -0400
Content-Disposition: inline
In-Reply-To: <b0675854-41f9-e7b6-4ad0-85ff59b98977@molgen.mpg.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Paul,

Sorry for this.


On 10/26/16 at 12:31pm, Paul Menzel wrote:
> > >         dev->hw_features = NETIF_F_IP_CSUM | NETIF_F_SG |
> > > @@ -8607,6 +8608,7 @@ bnx2_init_one(struct pci_dev *pdev, const struct
> > > pci_device_id *ent)
> > >         return 0;
> > > 
> > >  error:
> > > +       bnx2_release_firmware(bp);
> > >         pci_iounmap(pdev, bp->regview);
> > >         pci_release_regions(pdev);
> > >         pci_disable_device(pdev);
> 
> Baoquan, could you please fix this regression. My suggestion is, that you
> add the old code back, but check if the firmware has been loaded. If it
> hasn’t, load it again.
> 
> That way, people can update their Linux kernel, and it continues working
> without changing the initramfs, or anything else.

I saw your mail but I am also not familiar with bnx2 driver. As the
commit log says I just tried to make bnx2 driver reset itself earlier.

So you did a git bisect and found this commit caused the regression,
right? If yes, and network developers have no action, I will look into
the code and see if I have idea to fix it.

Thanks
Baoquan
