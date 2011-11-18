From: Rick Jones <rick.jones2@hp.com>
Subject: use a special value of -2 for virtual devices to report indeterminate
 speed?
Date: Fri, 18 Nov 2011 10:58:59 -0800
Message-ID: <4EC6AAF3.6080803@hp.com>
References: <20111118164805.GA14345@aepfle.de> <1321638394.2883.32.camel@bwh-desktop> <4EC6A778.1000503@hp.com> <4EC6A802.9090805@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Olaf Hering <olaf@aepfle.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0185.atlanta.hp.com ([15.193.32.62]:36624 "EHLO
	g6t0185.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754785Ab1KRS7c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2011 13:59:32 -0500
In-Reply-To: <4EC6A802.9090805@goop.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/18/2011 10:46 AM, Jeremy Fitzhardinge wrote:
> On 11/18/2011 10:44 AM, Rick Jones wrote:
>>   It could I suppose, decide
>> based on the physical NIC to which it is attached, so long as folks
>> using the virtual NIC don't expect its attributes to be the same from
>> system to system.
>
> And assuming there's a physical NIC at all.

It sounds like we need a way to specify "Indeterminate" for link speed? 
  Or some verbiage to that effect. Right now 0 and -1 cause ethtool to 
report "Unknown!"

         if (speed == 0 || speed == (u16)(-1) || speed == (u32)(-1))
                 fprintf(stdout, "Unknown!\n");
         else
                 fprintf(stdout, "%uMb/s\n", speed);


How about -2 for the u32 cast value of speed returning "Indeterminate" 
or something like that?  Not in "proper" patch format:

	if (speed == 0 || speed == (u16)(-1) || speed == (u32)(-1))
		fprintf(stdout, "Unknown!\n");
	else if (speed == (u32)(-2))
		fprintf(stdout, "Indeterminate.");
	else
		fprintf(stdout, "%uMb/s\n", speed);

Signed-off-by: Rick Jones <rick.jones2@hp.com>	

rick jones
