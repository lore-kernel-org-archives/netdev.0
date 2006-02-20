From: Alessandro Zummo <alessandro.zummo@towertech.it>
Subject: Re: [RFC] [PATCH 1/2] Driver to remember ethernet MAC values:
 maclist
Date: Mon, 20 Feb 2006 14:28:20 +0100
Message-ID: <20060220142820.279f766c@inspiron>
References: <20060220010113.GA19309@deprecation.cyrius.com>
	<20060220014735.GD4971@stusta.de>
	<20060220030146.11f418dc@inspiron>
	<43F9B32B.3090203@cantab.net>
	<20060220135718.038b675b@inspiron>
	<20060220130712.GA24784@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Vrabel <dvrabel@cantab.net>, Adrian Bunk <bunk@stusta.de>,
	Martin Michlmayr <tbm@cyrius.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	John Bowler <jbowler@acm.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030212AbWBTN2p@vger.kernel.org>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20060220130712.GA24784@xi.wantstofly.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 20 Feb 2006 14:07:12 +0100
Lennert Buytenhek <buytenh@wantstofly.org> wrote:

> >  you're certainly right on the ixp4xx, but the are other uses
> > for this driver which we are working on.. for example,
> > some Cirrus Logic ARM based chips (ep93xx) have an ethernet device
> > that could benefit from that.

> Many platforms have the same problem (esp. embedded ones), but that
> doesn't mean that maclist is necessarily the best solution.

 of course, that's why I wrote "maclist-alike"
 

> The main problem I see with maclist (correct me if I'm wrong) is that
> there can be multiple devices in the system that need to get their
> MAC address from somewhere, and maclist doesn't make the distinction
> which address belongs to what.  The main issue I have with it is that
> it's too general, and that it's lots of code.

 you're right, usually the first device will get the first mac
 and so on. it is general because it has been coded to be that way
 I think.


> I don't think something as complex as maclist is necessary to solve
> the problem.  For example, why don't you just have an unsigned char
> ixp4xx_mac_addr[6] in the ixp4xx core code, have the ixp4xx board code
> fill that in, and have the ixp4xx ethernet driver use that?
> 
> Or just pass the MAC along in platform device style.  What I did in
> drivers/net/ixp2000/ was to have enp2611.c (board-specific code) read
> the MAC from the board, and pass it to ixpdev.c (generic code) in the
> net_device structure.

 that perfectly doable, but maybe having one common interface could
 be a cleaner solution. your setup is board -> netdriver
 while maclist implements board -> storage -> netdriver.

 It is absolutely not a requirement, just a commodity. 

-- 

 Best regards,

 Alessandro Zummo,
  Tower Technologies - Turin, Italy

  http://www.towertech.it
