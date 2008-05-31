From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: PATCH for [Bug 8952] tulip driver oops in tulip_interrupt when
	hibernating with swsusp/suspend2
Date: Sat, 31 May 2008 17:54:16 -0600
Message-ID: <20080531235416.GA7909@colo.lackof.org>
References: <20080512063751.GH32317@colo.lackof.org> <4840B35F.7080807@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Grant Grundler <grundler@parisc-linux.org>, netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from colo.lackof.org ([198.49.126.79]:53273 "EHLO colo.lackof.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751593AbYEaXy2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 May 2008 19:54:28 -0400
Content-Disposition: inline
In-Reply-To: <4840B35F.7080807@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 30, 2008 at 10:09:35PM -0400, Jeff Garzik wrote:
> Grant Grundler wrote:
>> Jeff,
>> The following patch is seems to fix the tulip suspend/resume panic:
>> 	http://bugzilla.kernel.org/show_bug.cgi?id=8952#c46
>> My attempts at a cleaner patch failed and Pavel thinks this is OK.
>> Since suspend/resume is getting an overhaul in 2.6.27 (per comment
>> #49 by  Rafael J. Wysocki), it makes sense to invest more time as
>> part of that rework and apply the known fix to 2.6.26.
>> hth,
>> grant
>> Original from:  kernelbugs@tap.homeip.net
>> Signed-off-by: Grant Grundler <grundler@parisc-linux.org>
>> diff --git a/drivers/net/tulip/tulip_core.c 
>> b/drivers/net/tulip/tulip_core.c
>> index f9d13fa..088d3bf 100644
>> --- a/drivers/net/tulip/tulip_core.c
>> +++ b/drivers/net/tulip/tulip_core.c
>> @@ -1729,12 +1729,15 @@ static int tulip_suspend (struct pci_dev *pdev, 
>> pm_message_t state)
>>  	if (!dev)
>>  		return -EINVAL;
>>  -	if (netif_running(dev))
>> -		tulip_down(dev);
>> +	if (!netif_running(dev))
>> +		goto save_state:
>> +
>> +	tulip_down(dev);
>
> how could this be tested if it doesn't even compile?
> Oh well, seems sane, let's see...

Thanks for fixing up the : vs ;  and applying.
Is there a canonical description of what suspend/resume has to do?

As noted in the bug report, the NIC drivers are very inconsistent
in what they do in these routines.

thanks,
grant

