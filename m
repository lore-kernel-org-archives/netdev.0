From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: linux-next: manual merge of the net-next tree with the net tree
Date: Wed, 20 May 2015 20:29:01 -0700
Message-ID: <CAGVrzcY=Zf3BmSs2oEzc8Tmb=EHWcd_D+DB0fz1r=kiu9QyQKg@mail.gmail.com>
References: <20150521125924.7518d904@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	linux-next <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Tim Beale <tim.beale@alliedtelesis.co.nz>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:35500 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753181AbbEUD3n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 23:29:43 -0400
In-Reply-To: <20150521125924.7518d904@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-05-20 19:59 GMT-07:00 Stephen Rothwell <sfr@canb.auug.org.au>:
> Hi all,
>
> Today's linux-next merge of the net-next tree got a conflict in
> drivers/net/phy/phy.c between commit c15e10e71ce3 ("net: phy: Make sure
> phy_start() always re-enables the phy interrupts") from the net tree
> and commit 3e2186e02112 ("net: phy: Add state machine state transitions
> debug prints") from the net-next tree.
>
> I fixed it up (see below) and can carry the fix as necessary (no action
> is required).

Looks correct to me, thanks Stephen!

>
> --
> Cheers,
> Stephen Rothwell                    sfr@canb.auug.org.au
>
> diff --cc drivers/net/phy/phy.c
> index 47cd578052fc,1457ecf75dcc..000000000000
> --- a/drivers/net/phy/phy.c
> +++ b/drivers/net/phy/phy.c
> @@@ -783,7 -794,8 +808,8 @@@ void phy_state_machine(struct work_stru
>         struct delayed_work *dwork = to_delayed_work(work);
>         struct phy_device *phydev =
>                         container_of(dwork, struct phy_device, state_queue);
>  -      bool needs_aneg = false, do_suspend = false, do_resume = false;
>  +      bool needs_aneg = false, do_suspend = false;
> +       enum phy_state old_state;
>         int err = 0;
>
>         mutex_lock(&phydev->lock);



-- 
Florian
