From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [PATCH][NETNS]: Fix arbitrary net_device-s corruptions on net_ns
 stop.
Date: Wed, 07 May 2008 18:12:35 +0200
Message-ID: <4821D4F3.7000307@fr.ibm.com>
References: <48216398.9050509@openvz.org> <4821CBE5.5090801@fr.ibm.com> <4821CCD3.5020502@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:33085 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756457AbYEGQPH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2008 12:15:07 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate5.de.ibm.com (8.13.8/8.13.8) with ESMTP id m47GER2v248682
	for <netdev@vger.kernel.org>; Wed, 7 May 2008 16:14:27 GMT
Received: from d12av03.megacenter.de.ibm.com (d12av03.megacenter.de.ibm.com [9.149.165.213])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m47GERfo3784828
	for <netdev@vger.kernel.org>; Wed, 7 May 2008 18:14:27 +0200
Received: from d12av03.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av03.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m47GEQE8023358
	for <netdev@vger.kernel.org>; Wed, 7 May 2008 18:14:27 +0200
In-Reply-To: <4821CCD3.5020502@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov wrote:
>>> +		sprintf(fb_name, "dev%d", dev->ifindex);
>> The computed interface name can not exceed IFNAMSIZ, 3 ('dev') + 10 (max 
>> int) + 1 ('\0'). In this case there is no risk to corrupt the stack but 
>> may be it is more secure to change that to snprintf(fb_name, IFNAMSIZ, 
>> "dev%d", dev->ifindex), just in case, no ?
> 
> But you have just noticed, that "there is no risk to corrupt the stack"!
> What else can be "more secure" then :) ?

Just in case, for example, someone changes 'dev' by 'virtdev' or 
something else.
