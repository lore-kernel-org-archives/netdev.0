From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] fsl/fman: remove of_node
Date: Tue, 3 Oct 2017 15:00:32 +0200
Message-ID: <20171003130032.GI13548@lunn.ch>
References: <1506940297-20442-1-git-send-email-madalin.bucur@nxp.com>
 <20171002.160445.737065995396076298.davem@davemloft.net>
 <AM5PR0402MB26914CBD37E3F28C17562258EC720@AM5PR0402MB2691.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Madalin-cristian Bucur <madalin.bucur@nxp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([185.16.172.187]:37137 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751238AbdJCNAi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Oct 2017 09:00:38 -0400
Content-Disposition: inline
In-Reply-To: <AM5PR0402MB26914CBD37E3F28C17562258EC720@AM5PR0402MB2691.eurprd04.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 03, 2017 at 08:49:31AM +0000, Madalin-cristian Bucur wrote:
> > -----Original Message-----
> > From: David Miller [mailto:davem@davemloft.net]
> > Sent: Tuesday, October 03, 2017 2:05 AM
> > To: Madalin-cristian Bucur <madalin.bucur@nxp.com>
> > Subject: Re: [PATCH] fsl/fman: remove of_node
> > 
> > From: Madalin Bucur <madalin.bucur@nxp.com>
> > Date: Mon, 2 Oct 2017 13:31:37 +0300
> > 
> > > The FMan MAC driver allocates a platform device for the Ethernet
> > > driver to probe on. Setting pdev->dev.of_node with the MAC node
> > > triggers the MAC driver probing of the new platform device. While
> > > this fails quickly and does not affect the functionality of the
> > > drivers, it is incorrect and must be removed. This was added to
> > > address a report that DSA code using of_find_net_device_by_node()
> > > is unable to use the DPAA interfaces. Error message seen before
> > > this fix:
> > >
> > > fsl_mac dpaa-ethernet.0: __devm_request_mem_region(mac) failed
> > > fsl_mac: probe of dpaa-ethernet.0 failed with error -16
> > >
> > > Signed-off-by: Madalin Bucur <madalin.bucur@nxp.com>
> > 
> > Is the DSA issue no longer something we need to be concerned
> > about?  If not, why?  You have to explain this.
> 
> My patch removes the of_node that was set to a device that was not an
> of_device, preventing duplicated probing of both the real of_device
> and the "fake" one created through this assignment.
> 
> I understand that the DSA issue that triggered the initial change
> was related to DSA finding the network devices using 
> of_find_net_device_by_node(), something that will not work for the
> DPAA case where the netdevice does not have an of_node. I do not know
> enough about DSA to come up with a solution for this problem now.
> Andrew, Florian, can you please comment on this?
> 
> Thanks,

Hi Madalin

I guess the real fix is to throw away the platform device. But that is
a big change.

I've not looked at the code in detail. Why is the platform device
needed?

	Andrew
