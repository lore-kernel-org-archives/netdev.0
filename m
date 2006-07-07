From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH 1/3] Freescale QE UCC gigabit ethernet driver
Date: Fri, 7 Jul 2006 08:19:37 -0500
Message-ID: <02206875-0FBA-4390-A8AC-14D5446EBA50@kernel.crashing.org>
References: <4879B0C6C249214CBE7AB04453F84E4DF278@zch01exm20.fsl.freescale.net>
Mime-Version: 1.0 (Apple Message framework v750)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@osdl.org>, <jgarzik@pobox.com>,
	<netdev@vger.kernel.org>, <linuxppc-dev@ozlabs.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nommos.sslcatacombnetworking.com ([67.18.224.114]:38290 "EHLO
	nommos.sslcatacombnetworking.com") by vger.kernel.org with ESMTP
	id S1751199AbWGGNTv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jul 2006 09:19:51 -0400
In-Reply-To: <4879B0C6C249214CBE7AB04453F84E4DF278@zch01exm20.fsl.freescale.net>
To: Li Yang-r58472 <LeoLi@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Jul 7, 2006, at 3:59 AM, Li Yang-r58472 wrote:

>> -----Original Message-----
>> From: Kumar Gala [mailto:galak@kernel.crashing.org]
>> Sent: Thursday, July 06, 2006 9:45 PM
>> To: Li Yang-r58472
>> Cc: Andrew Morton; jgarzik@pobox.com; netdev@vger.kernel.org;
>> linuxppc-dev@ozlabs.org
>> Subject: Re: [PATCH 1/3] Freescale QE UCC gigabit ethernet driver
>>
>> Nack.  Here are some high level things that should be addressed:
>> * There is a ton of debug code that should probably be stripped out,
>> such as dump_regs, etc..
>
> The reason I left these debug code in is that, QE is very flexible.
> User probably needs to fine tune parameters for their own application.
> It will be good to give them some clue doing that.  It's fine to  
> remove
> them, if you do think they are too verbose.

Then I suggest you look at debugfs.

>> * The phy support should use the phylib instead
>
> I'll do this when I do get some time. ;)
>> * convert from being a platform_device to of_device
>
> I'm not up against moving to use of_device.  But why are we putting
> extra effort in closing the door to backward compatibility with ppc
> arch, and doesn't provide any new feature. ;)

Because the intent is for arch/ppc to go away in the future.  You are  
introducing a new driver and a new platform, this is the ideal time  
for us to use of_device.  The benefits are that the driver is the  
ideal place to parse the details of the device node rather than  
platform code in arch/powerpc.

- kumar
