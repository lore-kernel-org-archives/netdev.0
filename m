From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [hyperv] BUG at drivers/hv/channel.c:462 while changing MTU
Date: Mon, 25 Aug 2014 10:50:29 -0700
Message-ID: <20140825175029.GA25551@kroah.com>
References: <20140819123655.GC12160@sucs.org> <20140825093648.GB5046@mwanda>
 <cf94fd58947d4c5aa6d0d369c1126d7f@BY2PR0301MB0711.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 Jason Wang <jasowang@redhat.com>, Haiyang Zhang <haiyangz@microsoft.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Daniel Borkmann <dborkman@redhat.com>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 "David S. Miller" <davem@davemloft.net>,
 Dan Carpenter <dan.carpenter@oracle.com>, Sitsofe Wheeler <sitsofe@gmail.com>
To: KY Srinivasan <kys@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <cf94fd58947d4c5aa6d0d369c1126d7f@BY2PR0301MB0711.namprd03.prod.outlook.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 25, 2014 at 05:34:27PM +0000, KY Srinivasan wrote:
> 
> 
> > -----Original Message-----
> > From: Dan Carpenter [mailto:dan.carpenter@oracle.com]
> > Sent: Monday, August 25, 2014 2:37 AM
> > To: Sitsofe Wheeler
> > Cc: KY Srinivasan; Greg Kroah-Hartman; Jason Wang; linux-
> > kernel@vger.kernel.org; David S. Miller; Daniel Borkmann;
> > netdev@vger.kernel.org; devel@linuxdriverproject.org; Haiyang Zhang
> > Subject: Re: [hyperv] BUG at drivers/hv/channel.c:462 while changing MTU
> > 
> > The code here is:
> > 
> > drivers/hv/channel.c
> >    460          BUG_ON(ret != 0);
> >    461          t = wait_for_completion_timeout(&info->waitevent, 5*HZ);
> >    462          BUG_ON(t == 0);
> > 
> > So it calls BUG_ON() if the teardown takes more than 5 seconds.  It's most
> > likely that there is a race condition somewhere.  It's also possible that it's just
> > taking longer than 5 seconds for some odd reason and the bug would go
> > away if we raised it to 60 seconds.
> > 
> > BUG_ON() after 5 seconds seems like a very aggressive thing.
> 
> Dan,
> 
> I am going to audit all BUG_ON() instances.

Please remove them all, no kernel driver should ever crash the kernel
and not give a user a chance to recover :(

thanks,

greg k-h
