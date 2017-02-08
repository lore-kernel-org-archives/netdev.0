From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Kernel crashes in phy_attach_direct()
Date: Wed, 8 Feb 2017 15:28:57 +0100
Message-ID: <20170208142857.GD10855@lunn.ch>
References: <CAOMZO5C58--W1q+i26-+DBcton0Bk_o3zVfyuumM+Y=OemQ_Aw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:59995 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753259AbdBHPlA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 8 Feb 2017 10:41:00 -0500
Content-Disposition: inline
In-Reply-To: <CAOMZO5C58--W1q+i26-+DBcton0Bk_o3zVfyuumM+Y=OemQ_Aw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 08, 2017 at 10:58:57AM -0200, Fabio Estevam wrote:
> Hi,
> 
> I am getting the following kernel crash with linux-next 20170208
> running on a imx53-qsb board.
> 
> Any ideas?

Hi Fabio

Could you try reverting:

commit cafe8df8b9bc9aa3dffa827c1a6757c6cd36f657
Author: Mao Wenan <maowenan@huawei.com>
Date:   Tue Jan 31 18:46:43 2017 -0800

    net: phy: Fix lack of reference count on PHY driver
    
    There is currently no reference count being held on the PHY driver,
    which makes it possible to remove the PHY driver module while the PHY
    state machine is running and polling the PHY. This could cause crashes
    similar to this one to show up:

Thanks,
	Andrew
