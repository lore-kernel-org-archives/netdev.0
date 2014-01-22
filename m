From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] net: phy: use network device in
 phy_print_status
Date: Wed, 22 Jan 2014 11:05:06 -0800
Message-ID: <1390417506.31946.89.camel@joe-AO722>
References: <1390415553-4961-1-git-send-email-f.fainelli@gmail.com>
	 <1390416584.31946.84.camel@joe-AO722>
	 <CAGVrzcaDTOxBHNgSF1wme8JgnYV-KjpNfqqcNLdebqR0hjnWJg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0239.hostedemail.com ([216.40.44.239]:54899 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755997AbaAVTFK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 14:05:10 -0500
In-Reply-To: <CAGVrzcaDTOxBHNgSF1wme8JgnYV-KjpNfqqcNLdebqR0hjnWJg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-01-22 at 10:52 -0800, Florian Fainelli wrote:
> 2014/1/22 Joe Perches <joe@perches.com>:
> > On Wed, 2014-01-22 at 10:32 -0800, Florian Fainelli wrote:
> >> phy_print_status() currently uses dev_name(&phydev->dev) which will
> >> usually result in printing something along those lines for Device Tree
> >> aware drivers:
> >>
> >> libphy: f0b60000.etherne:0a - Link is Down
> >> libphy: f0ba0000.etherne:00 - Link is Up - 1000/Full
[]
> > The leading "- "'s now aren't useful and these could be
> 
> I did not want to remove the leading "- " since this would sort of
> produce a very different message now, that said, I have no strong
> feeling removing it.

The output would already be different as it's no longer
prefixed by "phylib: ".

With the dash it'll look like:

r8169 0000:01:00.0 eth3: - Link is Up

when all the other netdev_info link messages
don't use the - separator after the "ethX: "

> > It may also be possible to slightly improve the output by
> > reducing the number of 0's in the speed block and emitting
> > Kb/Mb/Gb (or Kbps/Mbps/Gbps) and maybe flow control if it's
> > available.
> 
> Sure thing, that calls for a follow-up patch though.

Thanks.
