From: Dinh Nguyen <dinguyen@opensource.altera.com>
Subject: Re: SoCFPGA ethernet broken
Date: Thu, 15 Oct 2015 21:32:18 -0500
Message-ID: <alpine.DEB.2.02.1510152102280.22844@linux-builds1>
References: <561FF9E2.30102@opensource.altera.com> <56200687.9040903@gmail.com> <562005AD.8020903@opensource.altera.com> <56200BD7.8020505@gmail.com> <56200E15.9080603@caviumnetworks.com> <56201158.8040806@opensource.altera.com>
 <56201AE7.2020103@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: David Daney <ddaney@caviumnetworks.com>,
	"David S. Miller" <davem@davemloft.net>, <david.daney@cavium.com>,
	<netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56201AE7.2020103@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 15 Oct 2015, Florian Fainelli wrote:

> On 15/10/15 13:49, Dinh Nguyen wrote:
> >>
> >> Does this text change with and without the 8b63ec1837fa patch?
> > 
> > No, this text does not change with/without the 8b63ec1837fa patch.
> 
> Could you instrument mdiobus_scan(), get_phy_device() and
> phy_device_create/register to see if the parent is NULL, non-NULL?
>

Yes, I can do that.
 
> So far, I cannot see what is wrong with David's changes, quite the
> contrary, and if there was something wrong with the PHY device creation,
> it should not get you that far.
> 
> You have not answered my previous question though, do you have PHY
> fixups registered for that ID?

By fixups, do you mean the skew values that are in the device tree?
Those are the only fixups that I have the PHY.

Another debugging point, the SoCFPGA board has a Micrel ksz9021 PHY attached
to the ethernet port. What I'm seeing is that with 8b63ec1837fa patch, when
the call to ksz9021_config_init() is made both of_node and dev->parent->of_node
are NULL, without the patch the dev->parent->of_node is a valid pointer. Thus
the skew values get programmed to the phy.

BR,
Dinh
