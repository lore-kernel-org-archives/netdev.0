From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [RFC PATCH linux-next] et131x: Promote staging et131x driver to
 drivers/net
Date: Tue, 22 Jan 2013 09:20:10 +0300
Message-ID: <20130122062010.GA16282@mwanda>
References: <1358541648-29922-1-git-send-email-mark.einon@gmail.com>
 <20130118225706.GA22140@kroah.com>
 <20130119110328.GO4584@mwanda>
 <CANK3SE2p3C38YrvCxWqvoRRz7=q7oAYyE=b0c7+ppBd3yzVrpw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org,
	sfr@canb.auug.org.au, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Mark Einon <mark.einon@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CANK3SE2p3C38YrvCxWqvoRRz7=q7oAYyE=b0c7+ppBd3yzVrpw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 21, 2013 at 11:44:55PM +0000, Mark Einon wrote:
> On 19 January 2013 11:03, Dan Carpenter <dan.carpenter@oracle.com> wrote:
> <snip>
> >
> > et131x_get_regs() has endian bugs calling et131x_mii_read().
> >
> </snip>
> 
> Hi Dan,
> 
> Could you be a bit more descriptive about the issues you think there
> are with these calls?
> 

Sorry, that was sloppy on my part.  Here's what I meant:

	et131x_mii_read(adapter, MII_BMCR, (u16 *)&regs_buff[num++]);

That puts the number in the 2 high bits which works for little
endian systems but not for big endian.  It should be something like:

	u16 tmp;

	et131x_mii_read(adapter, MII_BMCR, &tmp);
	regs_buff[num++] = tmp;

regards,
dan carpenter
