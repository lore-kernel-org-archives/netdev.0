From: Poornima Kamath <poornimak@gslab.com>
Subject: Re: Detecting backup slaves of bonding interface in network driver
Date: Mon, 29 Dec 2008 15:58:49 +0530
Message-ID: <4958A661.9020601@gslab.com>
References: <494108D7.3040304@gslab.com> <25821.1229013359@death.nxdomain.ibm.com> <4942663A.3080801@gslab.com> <3481.1229099865@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from padma.gslab.com ([59.163.66.102]:38450 "HELO padma.gslab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753246AbYL2K2x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Dec 2008 05:28:53 -0500
In-Reply-To: <3481.1229099865@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jay,

 Thanks a lot for your  response.
 ib-bonding does have  fail_over_mac functionality and works on both 
RHEL5 and SLES10.

Thanks,
Poornima

Jay Vosburgh wrote:
> Poornima Kamath <poornimak@gslab.com> wrote:
>
>   
>> The driver creates virtual interfaces that talk to ethernet interfaces over
>> infiniband,  using an infiniband to ethernet gateway device.
>> The gateway device sends data to all interfaces having same mac address.  For
>> this the driver needs to explicitly tell the gateway device not to send data to
>> the backup slaves.
>> Therefore the driver needs to  know which slaves are backup slaves.
>> The failover mac option  works well,  but it is present for kernels greater
>> than 2.6.24.  So this option is not available for distros like RHEL5, SLES10
>> etc
>>     
>
> 	I believe that RHEL5 and SLES10 contain an "ib-bonding" package
> which includes a backport of the current (or at least a more current)
> bonding driver specifically for use over Infiniband.  I think it's also
> got a couple of other patches to bonding that aren't in the mainline.
> In any event, it has the fail_over_mac functionality.
>
> 	Have you looked at ib-bonding?
>
>   
>> So in order to support these distros I need some way of identifying the backup
>> slaves.
>> Is it ok to check the IFF_SLAVE_INACTIVE flags for these distros?
>>     
>
> 	It will do what you want (identify backup slaves), and is not
> guaranteed to be available in the future.  I doubt that the flag would
> ever go away on RHEL5 or SLES10, but, again, no guarantee.
>
> 	-J
>
> ---
> 	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>   

