From: "Ariel Elior" <ariele@broadcom.com>
Subject: RE: [PATCH net-next 06/13] bnx2x: Control number of vfs
 dynamically
Date: Tue, 12 Mar 2013 10:51:13 +0000
Message-ID: <6AE768456CEC4B4A9B2248CB6B87EB3E1BD10E88@SJEXCHMB05.corp.ad.broadcom.com>
References: <1363015073-25743-1-git-send-email-yuvalmin@broadcom.com>
 <1363015073-25743-7-git-send-email-yuvalmin@broadcom.com>
 <20130312.052811.2289109881056913990.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>,
	"Yuval Mintz" <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3441 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932519Ab3CLKvr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Mar 2013 06:51:47 -0400
In-Reply-To: <20130312.052811.2289109881056913990.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Tuesday, March 12, 2013 11:28 AM
> To: Yuval Mintz
> Cc: netdev@vger.kernel.org; Eilon Greenstein; Ariel Elior
> Subject: Re: [PATCH net-next 06/13] bnx2x: Control number of vfs
> dynamically
> 
> From: "Yuval Mintz" <yuvalmin@broadcom.com>
> Date: Mon, 11 Mar 2013 17:17:46 +0200
> 
> > From: Ariel Elior <ariele@broadcom.com>
> >
> > 1. Support sysfs interface for getting the maximal number of virtual
> functions
> >    of a given physical function.
> > 2. Support sysfs interface for getting and setting the current number of
> >    virtual functions.
> >
> > Signed-off-by: Ariel Elior <ariele@broadcom.com>
> > Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
> > Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
> 
> I don't like these sysfs knobs at all, what are other drivers
> doing?

Intel's ixgbe and igb already implement these callbacks.
Other drivers are using proprietary module parameters.
This is a generic sysfs interface which any driver can use.

Yuval Mintz from Broadcom started the
"New commands to configure IOV features" thread
http://marc.info/?l=linux-netdev&m=133638974914452&w=2
As the discussion developed it was realized that virtual functions
have a wider scope than networking.
The discussion culminated with a submission to the pci tree:
commit 1789382a72a537447d65ea4131d8bcc1ad85ce7b
Author: Donald Dutile <ddutile@redhat.com>
Date:   Mon Nov 5 15:20:36 2012 -0500

Adding sriov_numvfs and sriov_totalvfs to all SR-IOV capable pci devices.
I would like to add that sysfs is actually a very convenient place to have 
these knobs, because the virtfn entries there are a simple reliable way to
know which vf devices sprouted from which PF devices and what are their
names, which is very handy when scripting with VFs.

Thanks,
Ariel
