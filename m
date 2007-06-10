From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH 3/4] NetXen: Add correct routines to setup multicast address
Date: Sun, 10 Jun 2007 11:59:25 +0200
Message-ID: <200706101159.25756.mb@bu3sch.de>
References: <200706071134.l57BYbpH007596@dut39.unminc.com> <200706101154.11746.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amitkale@netxen.com, jeff@garzik.org,
	netxenproj@linsyssoft.com, rob@netxen.com
To: Mithlesh Thukral <mithlesh@netxen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:59771
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752182AbXFJKAZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jun 2007 06:00:25 -0400
In-Reply-To: <200706101154.11746.mb@bu3sch.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 10 June 2007 11:54:11 Michael Buesch wrote:
> > +int netxen_nic_set_mcast_addr(struct netxen_adapter *adapter, int index, 
> > +				u8 *addr)
> > +{
> > +	u32 hi = 0;
> > +	u32 lo = 0;
> > +	u16 port = physical_port[adapter->portnum];
> > +
> > +	hi = (u32) addr[0] | 
> > +		((u32) addr[1] << 8) |
> > +		((u32) addr[2] << 16);
> > +	lo = (u32) addr[3] |
> > +		((u32) addr[4] << 8) |
> > +		((u32) addr[5] << 16);
> 
> That is the correct solution. Do that above, too.
> 
> > +	netxen_crb_writelit_adapter(adapter, NETXEN_MCAST_ADDR(port,index), hi);
> > +	netxen_crb_writelit_adapter(adapter, NETXEN_MCAST_ADDR(port,index) + 4,
> > +					hi);
> > +	return 0;
> > +}

Well, actually no. It is broken, too. You write hi twice. And I would
swap the variable names, as "low" is addr[0] in my understanding.



-- 
Greetings Michael.
