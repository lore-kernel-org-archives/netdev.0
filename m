From: Karsten Keil <kkeil@linux-pingi.de>
Subject: Re: [patch] isdn: make sure strings are null terminated
Date: Thu, 24 Nov 2011 14:17:20 +0100
Message-ID: <20111124131720.GA16966@gw.linux-pingi.de>
References: <20111123064204.GA6871@elgon.mountain>
 <4ECCAE14.3070008@bfs.de>
 <20111124113456.GI3258@mwanda>
 <4ECE36D6.7060503@bfs.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Carpenter <dan.carpenter@oracle.com>,
	Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: walter harms <wharms@bfs.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:52016 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755879Ab1KXNR2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2011 08:17:28 -0500
Content-Disposition: inline
In-Reply-To: <4ECE36D6.7060503@bfs.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 24, 2011 at 01:21:42PM +0100, walter harms wrote:
> 
> 
> Am 24.11.2011 12:34, schrieb Dan Carpenter:
> > On Wed, Nov 23, 2011 at 09:25:56AM +0100, walter harms wrote:
> >>
> >>
> >> Am 23.11.2011 07:42, schrieb Dan Carpenter:
> >>> These strings come from the user.  We strcpy() them inside
> >>> cf_command() so we should check that they are NULL terminated and
> >>> return an error if not.
> >>>
> >>> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> >>>
> >>> diff --git a/drivers/isdn/divert/divert_procfs.c b/drivers/isdn/divert/divert_procfs.c
> >>> index 33ec9e4..0c16687 100644
> >>> --- a/drivers/isdn/divert/divert_procfs.c
> >>> +++ b/drivers/isdn/divert/divert_procfs.c
> >>> @@ -242,6 +242,10 @@ static int isdn_divert_ioctl_unlocked(struct file *file, uint cmd, ulong arg)
> >>>  		case IIOCDOCFINT:
> >>>  			if (!divert_if.drv_to_name(dioctl.cf_ctrl.drvid))
> >>>  				return (-EINVAL);	/* invalid driver */
> >>> +			if (strlen(dioctl.cf_ctrl.msn) >= sizeof(dioctl.cf_ctrl.msn))
> >>> +				return -EINVAL;
> >>> +			if (strlen(dioctl.cf_ctrl.fwd_nr) >= sizeof(dioctl.cf_ctrl.fwd_nr))
> >>> +				return -EINVAL;
> >>
> >> forcing the last field to be zero seems more easy.
> >> dioctl.cf_ctrl.fwd_nr[sizeof(dioctl.cf_ctrl.fwd_nr))-1]=0;
> >>
> > 
> > That's a valid option to use, but I'd prefer to return an error code
> > here because that's what we do on the line before.  Passing a too
> > long string is clearly invalid.
> > 
> 
> the line before has the same problem, of cause.
> 
> So far i see you do not get a string, you get a structure. An it will hard
> to validate the element is a useful string. I thing my (sledgehammer) method
> is ok here because you make sure that all later calls (strcmp,strcpy) will succeed.
> If someone supplies a bad string the later calls will catch by failing to identify
> and return a proper code from there (at least i hope so).
> 

Since the proper userspace programs should use the correct size, these valid
fixes (Thanks !) will prevent bad programs to use this for some bad purpose.
I think both methods are OK, I tend to the sledgehammer, because it is the
lowest CPU consuming method - but on the other side the valid length is
small enough.

Thanks
Karsten
