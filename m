From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 0/5] Call netif_carrier_off() after register_netdev()
Date: Wed, 15 Aug 2012 13:40:52 +0200
Message-ID: <87boicz8l7.fsf@nemi.mork.no>
References: <1344940135-17079-1-git-send-email-shchepetkov@ispras.ru>
	<20120814.140019.1016184364798213214.davem@davemloft.net>
	<1344984477.2690.85.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, <shchepetkov@ispras.ru>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<ldv-project@ispras.ru>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344984477.2690.85.camel@bwh-desktop.uk.solarflarecom.com> (Ben
	Hutchings's message of "Tue, 14 Aug 2012 23:47:57 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Hutchings <bhutchings@solarflare.com> writes:

> But if you do it beforehand then it doesn't have the intended effect.
> (Supposed to be fixed by 22604c866889c4b2e12b73cbf1683bda1b72a313, wh=
ich
> had to be reverted: c276e098d3ee33059b4a1c747354226cec58487c.)
>
> So you have to do it after, but without dropping the RTNL lock in
> between.

So you may want to add something like

int register_netdev_carrier_off(struct net_device *dev)
{
	int err;

	rtnl_lock();
	err =3D register_netdevice(dev);
        if (!err)
                set_bit(__LINK_STATE_NOCARRIER, &dev->state)
	rtnl_unlock();
	return err;
}


for these drivers?



Bj=C3=B8rn
