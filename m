From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [RFT][PATCH] cleanup net/atm/br2684.c
Date: Mon, 11 Aug 2003 15:30:39 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030811153039.6df304fb.shemminger@osdl.org>
References: <20030811114823.5b81474c.shemminger@osdl.org>
	<20030811215857.GA96728@gaz.sfgoth.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: chas williams <chas@cmf.nrl.navy.mil>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mitchell Blank Jr <mitch@sfgoth.com>
In-Reply-To: <20030811215857.GA96728@gaz.sfgoth.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 11 Aug 2003 14:58:57 -0700
Mitchell Blank Jr <mitch@sfgoth.com> wrote:

> You might also want to send this patch to the linux-atm mailing list:
>   linux-atm-general@lists.sourceforge.net
> Unfortunately you need to subscribe to post.
>   http://lists.sourceforge.net/lists/listinfo/linux-atm-general
> 
> Not sure how many ATM users are following 2.6 yet though.  I might be
> able to give it a spin soon.
> 
> > -			unregister_netdev(&brdev->net_dev);
> > -			kfree(brdev);
> > +			unregister_netdev(brdev->net_dev);
> > +			kfree(brdev->net_dev);
> 
> Mmmm.. I see this snippet in your diff in multiplce places and it looks
> wrong.  Where does the "brdev" structure get freed now?
> 
> -Mitch
The brdev structure is contained inside the allocation of net_device,
this is how all the ether and other devices do it.

net_dev   -->+-------------------+
             | network_device    |
             +-------------------+
             |/// padding ///////|
             +-------------------+
priv      -->|     brdev         |
             +-------------------+

	
