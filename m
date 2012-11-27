From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [net-next 06/10] ixgbe: eliminate Smatch warnings in
 ixgbe_debugfs.c
Date: Tue, 27 Nov 2012 10:18:04 +0300
Message-ID: <20121127071804.GR6186@mwanda>
References: <1353494856-12344-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1353494856-12344-7-git-send-email-jeffrey.t.kirsher@intel.com>
 <20121121110409.GG6186@mwanda>
 <4329753313F5A742A09953EE6CC1B3CE28C7D984@ORSMSX108.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: "Hay, Joshua A" <joshua.a.hay@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:25864 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758148Ab2K0HSS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2012 02:18:18 -0500
Content-Disposition: inline
In-Reply-To: <4329753313F5A742A09953EE6CC1B3CE28C7D984@ORSMSX108.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 27, 2012 at 01:06:17AM +0000, Hay, Joshua A wrote:
> The return value will be changed to len to preserve error codes returned from simple_write_to_buffer.
> 
> However, changing the logic preceding this return breaks these functions.  If simple_write_to_buffer returns a positive value, other actions are performed with this value.  With this patch, the function will return immediately with that value instead.  This will effectively break the ixgbe_debugfs write operations.
> 
> So ultimately, the change should be: 
> > +	len = simple_write_to_buffer(ixgbe_dbg_reg_ops_buf,
> > +				     sizeof(ixgbe_dbg_reg_ops_buf)-1,
> > +				     ppos,
> > +				     buffer,
> > +				     count);
> > +	if (len < 0)
> > +		return -EFAULT;
> 	
> 	if (len < 0)
> 		return len;
> 

Yes.  Sorry, I wasn't reading carefully before.  That looks fine.

regards,
dan carpenter
