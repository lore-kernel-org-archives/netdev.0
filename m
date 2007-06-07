From: Pavel Emelianov <xemul@openvz.org>
Subject: Re: [PATCH] Virtual ethernet tunnel
Date: Thu, 07 Jun 2007 19:33:26 +0400
Message-ID: <46682546.30908@openvz.org>
References: <4666CEAA.8010903@openvz.org> <4666D296.2000002@trash.net>	<4667BD1D.9080905@openvz.org> <4667D00E.2020605@fr.ibm.com>	<4667D538.7040904@openvz.org> <466810BF.2090704@fr.ibm.com> <466814CA.3070909@sw.ru> <46681941.30403@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Kirill Korotaev <dev@openvz.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Containers <containers@lists.osdl.org>,
	Patrick McHardy <kaber@trash.net>
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:3610 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751462AbXFGP2u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jun 2007 11:28:50 -0400
In-Reply-To: <46681941.30403@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>
>> no one is against generic code and ability to create 2 interfaces in
>> *one* namespace.
>> (Like we currently allow to do so in OpenVZ)
>>
>> However, believe me, moving an interface is a *hard* operation. Much
>> harder then netdev
>> register from the scratch.
>>
>> Because it requires to take into account many things like:
>> - packets in flight which requires synchronize and is slow on big
>> machines
>> - asynchronous sysfs entries registration/deregistration from
>>   rtln_unlock -> netdev_run_todo
>> - name/ifindex collisions
>> - shutdown/cleanup of addresses/routes/qdisc and other similar stuff
>>
>>   
> All of what you are describing is already implemented in the Eric's
> patchset.

Daniel. We *agree* that this task *is implementable*. We just want
to say that creating the device in the namespace is less comp...
(oh, well, forget this word) faster than creating and then moving.

> You can have a look at :
> 
> http://lxc.sourceforge.net/patches/2.6.20/2.6.20-netns1/broken_out/
> 
> And more precisly:
> 
> for sysfs issues:
> http://lxc.sourceforge.net/patches/2.6.20/2.6.20-netns1/broken_out/0065-sysfs-Shadow-directory-support.patch
> 
> 
> for network device movement:
> http://lxc.sourceforge.net/patches/2.6.20/2.6.20-netns1/broken_out/0096-net-Implment-network-device-movement-between-namesp.patch

Good job. Can you prove that this code is less buggy than the existing
register_netdevice() one? This requires testing, doesn't it? But on the
other hand we have the ability to create the device right in the namespace
using well known (and thus well debugged) code with minimal actions from
the kernel.

> 
> Thanks,
> Daniel
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

