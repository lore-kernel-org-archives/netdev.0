From: walter harms <wharms@bfs.de>
Subject: Re: [patch] isdn: make sure strings are null terminated
Date: Thu, 24 Nov 2011 13:21:42 +0100
Message-ID: <4ECE36D6.7060503@bfs.de>
References: <20111123064204.GA6871@elgon.mountain> <4ECCAE14.3070008@bfs.de> <20111124113456.GI3258@mwanda>
Reply-To: wharms@bfs.de
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx01.sz.bfs.de ([194.94.69.103]:10449 "EHLO mx01.sz.bfs.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750757Ab1KXMVp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Nov 2011 07:21:45 -0500
In-Reply-To: <20111124113456.GI3258@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Am 24.11.2011 12:34, schrieb Dan Carpenter:
> On Wed, Nov 23, 2011 at 09:25:56AM +0100, walter harms wrote:
>>
>>
>> Am 23.11.2011 07:42, schrieb Dan Carpenter:
>>> These strings come from the user.  We strcpy() them inside
>>> cf_command() so we should check that they are NULL terminated and
>>> return an error if not.
>>>
>>> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>>>
>>> diff --git a/drivers/isdn/divert/divert_procfs.c b/drivers/isdn/divert/divert_procfs.c
>>> index 33ec9e4..0c16687 100644
>>> --- a/drivers/isdn/divert/divert_procfs.c
>>> +++ b/drivers/isdn/divert/divert_procfs.c
>>> @@ -242,6 +242,10 @@ static int isdn_divert_ioctl_unlocked(struct file *file, uint cmd, ulong arg)
>>>  		case IIOCDOCFINT:
>>>  			if (!divert_if.drv_to_name(dioctl.cf_ctrl.drvid))
>>>  				return (-EINVAL);	/* invalid driver */
>>> +			if (strlen(dioctl.cf_ctrl.msn) >= sizeof(dioctl.cf_ctrl.msn))
>>> +				return -EINVAL;
>>> +			if (strlen(dioctl.cf_ctrl.fwd_nr) >= sizeof(dioctl.cf_ctrl.fwd_nr))
>>> +				return -EINVAL;
>>
>> forcing the last field to be zero seems more easy.
>> dioctl.cf_ctrl.fwd_nr[sizeof(dioctl.cf_ctrl.fwd_nr))-1]=0;
>>
> 
> That's a valid option to use, but I'd prefer to return an error code
> here because that's what we do on the line before.  Passing a too
> long string is clearly invalid.
> 

the line before has the same problem, of cause.

So far i see you do not get a string, you get a structure. An it will hard
to validate the element is a useful string. I thing my (sledgehammer) method
is ok here because you make sure that all later calls (strcmp,strcpy) will succeed.
If someone supplies a bad string the later calls will catch by failing to identify
and return a proper code from there (at least i hope so).

re,
 wh
