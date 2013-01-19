From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [RFC PATCH linux-next] et131x: Promote staging et131x driver to
 drivers/net
Date: Sat, 19 Jan 2013 14:03:28 +0300
Message-ID: <20130119110328.GO4584@mwanda>
References: <1358541648-29922-1-git-send-email-mark.einon@gmail.com>
 <20130118225706.GA22140@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mark Einon <mark.einon@gmail.com>, devel@driverdev.osuosl.org,
	sfr@canb.auug.org.au, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130118225706.GA22140@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 18, 2013 at 02:57:06PM -0800, Greg KH wrote:
> On Fri, Jan 18, 2013 at 08:40:47PM +0000, Mark Einon wrote:
> > This patch moves the et131x gigabit ethernet driver from drivers/staging
> > to drivers/net/ethernet/agere.
> > 
> > All the existing issues noted for this driver have been resolved, apart
> > from one performance issue where some fragmented packets suffer from
> > frame receive errors. As I've only tested the code on one piece of
> > hardware to date, it would be useful to get feedback on this issue from
> > any other users of the device (my device has been stepped on several times
> > now, and is known to need a few wiggles before starting up correctly).
> > 
> > Signed-off-by: Mark Einon <mark.einon@gmail.com>
> 
> No objection from me for this.  It's up to the network driver
> maintainers if this is ok or not.
> 

et131x_get_regs() has endian bugs calling et131x_mii_read().

There are a bunch of sparse warnings as well.  I haven't looked at
them because it's the weekend.

drivers/staging/et131x/et131x.c:1870:33: warning: incorrect type in assignment (different address spaces)
drivers/staging/et131x/et131x.c:1870:33:    expected unsigned int [usertype] *num_des
drivers/staging/et131x/et131x.c:1870:33:    got unsigned int [noderef] <asn:2>*<noident>
drivers/staging/et131x/et131x.c:1871:37: warning: incorrect type in assignment (different address spaces)
drivers/staging/et131x/et131x.c:1871:37:    expected unsigned int [usertype] *full_offset
drivers/staging/et131x/et131x.c:1871:37:    got unsigned int [noderef] <asn:2>*<noident>
drivers/staging/et131x/et131x.c:1872:33: warning: incorrect type in assignment (different address spaces)
drivers/staging/et131x/et131x.c:1872:33:    expected unsigned int [usertype] *min_des
drivers/staging/et131x/et131x.c:1872:33:    got unsigned int [noderef] <asn:2>*<noident>
drivers/staging/et131x/et131x.c:1873:33: warning: incorrect type in assignment (different address spaces)
drivers/staging/et131x/et131x.c:1873:33:    expected unsigned int [usertype] *base_hi
drivers/staging/et131x/et131x.c:1873:33:    got unsigned int [noderef] <asn:2>*<noident>
drivers/staging/et131x/et131x.c:1874:33: warning: incorrect type in assignment (different address spaces)
drivers/staging/et131x/et131x.c:1874:33:    expected unsigned int [usertype] *base_lo
drivers/staging/et131x/et131x.c:1874:33:    got unsigned int [noderef] <asn:2>*<noident>
drivers/staging/et131x/et131x.c:1876:33: warning: incorrect type in assignment (different address spaces)
drivers/staging/et131x/et131x.c:1876:33:    expected unsigned int [usertype] *num_des
drivers/staging/et131x/et131x.c:1876:33:    got unsigned int [noderef] <asn:2>*<noident>
drivers/staging/et131x/et131x.c:1877:37: warning: incorrect type in assignment (different address spaces)
drivers/staging/et131x/et131x.c:1877:37:    expected unsigned int [usertype] *full_offset
drivers/staging/et131x/et131x.c:1877:37:    got unsigned int [noderef] <asn:2>*<noident>
drivers/staging/et131x/et131x.c:1878:33: warning: incorrect type in assignment (different address spaces)
drivers/staging/et131x/et131x.c:1878:33:    expected unsigned int [usertype] *min_des
drivers/staging/et131x/et131x.c:1878:33:    got unsigned int [noderef] <asn:2>*<noident>
drivers/staging/et131x/et131x.c:1879:33: warning: incorrect type in assignment (different address spaces)
drivers/staging/et131x/et131x.c:1879:33:    expected unsigned int [usertype] *base_hi
drivers/staging/et131x/et131x.c:1879:33:    got unsigned int [noderef] <asn:2>*<noident>
drivers/staging/et131x/et131x.c:1880:33: warning: incorrect type in assignment (different address spaces)
drivers/staging/et131x/et131x.c:1880:33:    expected unsigned int [usertype] *base_lo
drivers/staging/et131x/et131x.c:1880:33:    got unsigned int [noderef] <asn:2>*<noident>
drivers/staging/et131x/et131x.c:1898:24: warning: incorrect type in argument 2 (different address spaces)
drivers/staging/et131x/et131x.c:1898:24:    expected void volatile [noderef] <asn:2>*addr
drivers/staging/et131x/et131x.c:1898:24:    got unsigned int [usertype] *base_hi
drivers/staging/et131x/et131x.c:1900:24: warning: incorrect type in argument 2 (different address spaces)
drivers/staging/et131x/et131x.c:1900:24:    expected void volatile [noderef] <asn:2>*addr
drivers/staging/et131x/et131x.c:1900:24:    got unsigned int [usertype] *base_lo
drivers/staging/et131x/et131x.c:1901:60: warning: incorrect type in argument 2 (different address spaces)
drivers/staging/et131x/et131x.c:1901:60:    expected void volatile [noderef] <asn:2>*addr
drivers/staging/et131x/et131x.c:1901:60:    got unsigned int [usertype] *num_des
drivers/staging/et131x/et131x.c:1902:39: warning: incorrect type in argument 2 (different address spaces)
drivers/staging/et131x/et131x.c:1902:39:    expected void volatile [noderef] <asn:2>*addr
drivers/staging/et131x/et131x.c:1902:39:    got unsigned int [usertype] *full_offset
drivers/staging/et131x/et131x.c:1910:24: warning: incorrect type in argument 2 (different address spaces)
drivers/staging/et131x/et131x.c:1910:24:    expected void volatile [noderef] <asn:2>*addr
drivers/staging/et131x/et131x.c:1910:24:    got unsigned int [usertype] *min_des
drivers/staging/et131x/et131x.c:2583:32: warning: incorrect type in assignment (different address spaces)
drivers/staging/et131x/et131x.c:2583:32:    expected unsigned int [usertype] *offset
drivers/staging/et131x/et131x.c:2583:32:    got unsigned int [noderef] <asn:2>*<noident>
drivers/staging/et131x/et131x.c:2585:32: warning: incorrect type in assignment (different address spaces)
drivers/staging/et131x/et131x.c:2585:32:    expected unsigned int [usertype] *offset
drivers/staging/et131x/et131x.c:2585:32:    got unsigned int [noderef] <asn:2>*<noident>
drivers/staging/et131x/et131x.c:2602:24: warning: incorrect type in argument 2 (different address spaces)
drivers/staging/et131x/et131x.c:2602:24:    expected void volatile [noderef] <asn:2>*addr
drivers/staging/et131x/et131x.c:2602:24:    got unsigned int [usertype] *offset
drivers/staging/et131x/et131x.c:4093:13: warning: symbol 'et131x_isr' was not declared. Should it be static?
  CC [M]  drivers/staging/et131x/et131x.o

regards,
dan carpenter
