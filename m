From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 6/6] amd-xgbe: Resolve checkpatch warning about
 sscanf usage
Date: Tue, 24 Jun 2014 15:53:30 -0700
Message-ID: <1403650410.11163.2.camel@joe-AO725>
References: <20140624211900.20681.46554.stgit@tlendack-t1.amdoffice.net>
	 <20140624211935.20681.85586.stgit@tlendack-t1.amdoffice.net>
	 <1403647225.29061.64.camel@joe-AO725> <53A9FF42.2090502@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Tom Lendacky <thomas.lendacky@amd.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0146.hostedemail.com ([216.40.44.146]:41452 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752281AbaFXWxe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2014 18:53:34 -0400
In-Reply-To: <53A9FF42.2090502@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-06-24 at 17:44 -0500, Tom Lendacky wrote:
> On 06/24/2014 05:00 PM, Joe Perches wrote:
> > On Tue, 2014-06-24 at 16:19 -0500, Tom Lendacky wrote:
> >> Checkpatch issued a warning preferring to use kstrto<type> when
> >> using a single variable sscanf.  Change the sscanf invocation to
> >> a kstrtouint call.
> > []
> >> diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c b/drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c
> > []
> >> @@ -165,10 +165,9 @@ static ssize_t xgbe_common_write(const char __user *buffer, size_t count,
> >>   		return len;
> >>
> >>   	workarea[len] = '\0';
> >> -	if (sscanf(workarea, "%x", &scan_value) == 1)
> >> -		*value = scan_value;
> >> -	else
> >> -		return -EIO;
> >> +	ret = kstrtouint(workarea, 0, value);
> >
> > Don't you need to use 16 for the base here?

> Using 0 allows for greater flexibility in the input format.

True, but there could be a change in behavior like reading a
previously hex value like 10 is now a decimal 10 not decimal 16.

> > Are there any issues with any of the various callers
> > getting a different error return?
> >
> > -EINVAL/-ERANGE vs -EIO ?
> There shouldn't be, but I can always return -EIO to be
> consistent with how it was previously.

Up to you Tom.  I just wanted you to think about it.

cheers, Joe
