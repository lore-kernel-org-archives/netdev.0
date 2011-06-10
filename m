From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 3/5 net-next] cnic: Randomize initial TCP port for iSCSI
 connections
Date: Thu, 9 Jun 2011 21:01:57 -0700
Message-ID: <20110609210157.6a1f016b@nehalam.ftrdhcpuser.net>
References: <1307597376-5379-1-git-send-email-mchan@broadcom.com>
	<1307597376-5379-2-git-send-email-mchan@broadcom.com>
	<1307597376-5379-3-git-send-email-mchan@broadcom.com>
	<20110609082722.492b46b5@nehalam.ftrdhcpuser.net>
	<1307668080.14980.13.camel@HP1>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eddie Wai" <eddie.wai@broadcom.com>
To: "Michael Chan" <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42356 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750720Ab1FJECB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jun 2011 00:02:01 -0400
In-Reply-To: <1307668080.14980.13.camel@HP1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 9 Jun 2011 18:08:00 -0700
"Michael Chan" <mchan@broadcom.com> wrote:

> 
> On Thu, 2011-06-09 at 08:27 -0700, Stephen Hemminger wrote:
> > On Wed, 8 Jun 2011 22:29:34 -0700
> > "Michael Chan" <mchan@broadcom.com> wrote:
> > 
> > >  static int cnic_cm_alloc_mem(struct cnic_dev *dev)
> > >  {
> > >  	struct cnic_local *cp = dev->cnic_priv;
> > > +	u32 port_id;
> > >  
> > >  	cp->csk_tbl = kzalloc(sizeof(struct cnic_sock) * MAX_CM_SK_TBL_SZ,
> > >  			      GFP_KERNEL);
> > >  	if (!cp->csk_tbl)
> > >  		return -ENOMEM;
> > >  
> > > +	get_random_bytes(&port_id, sizeof(port_id));
> > 
> > I think random32() or it's alias net_random() would be sufficient
> > for your needs here.
> > 
> 
> random32() is pseudo random so we can get the same number after reboot,
> right?  One scenario is that we may be booting from an iSCSI target, but
> due to some failure, the user may be rebooting multiple times rapidly.
> We want to use a different port during each boot.

random32 is seeded off get_random_bytes at boot.
