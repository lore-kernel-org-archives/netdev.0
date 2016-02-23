From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 3/9] mlx4: Implement port type setting via
 devlink interface
Date: Tue, 23 Feb 2016 17:04:58 +0100
Message-ID: <20160223160458.GM2140@nanopsycho.orion>
References: <1456165924-14399-1-git-send-email-jiri@resnulli.us>
 <1456165924-14399-4-git-send-email-jiri@resnulli.us>
 <56CC41C8.10802@stressinduktion.org>
 <20160223122109.GD2140@nanopsycho.orion>
 <56CC5E65.40809@stressinduktion.org>
 <20160223142626.GF2140@nanopsycho.orion>
 <56CC77BB.60601@stressinduktion.org>
 <20160223153023.GJ2140@nanopsycho.orion>
 <56CC815D.9070009@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
	yishaih@mellanox.com, dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, eugenia@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	hadarh@mellanox.com, jhs@mojatatu.com, john.fastabend@gmail.com,
	jeffrey.t.kirsher@intel.com, brouer@redhat.com, ivecera@redhat.com,
	rami.rosen@intel.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:32814 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752374AbcBWQFB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 11:05:01 -0500
Received: by mail-wm0-f46.google.com with SMTP id g62so207611489wme.0
        for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 08:05:01 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <56CC815D.9070009@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Feb 23, 2016 at 04:57:17PM CET, hannes@stressinduktion.org wrote:
>On 23.02.2016 16:30, Jiri Pirko wrote:
>>Tue, Feb 23, 2016 at 04:16:11PM CET, hannes@stressinduktion.org wrote:
>>
>><snip>
>>
>>>>>1) is easily solvable, just drop the ifindex style attributes and always
>>>>>force the user to enter the bus and bus-topology id.
>>>>
>>>>But why? Use can easily get that info and map it to devlink index. It
>>>>aligns with nl80211 iface.
>>>>
>>>>Do you really want to do commands like:
>>>>myhost:~$ dl dev show pci_0000:01:00.0
>>>>?
>>>
>>>Yes, exactly I would. I would put them into a boot-up script based on my
>>>system configuration and can be sure it will work the next boot, too, and
>>>adapt them when I replace the hardware or do some configuration changes.
>>>
>>>I think sysadmins or scripts are the primary users of this interface not
>>>kernel developers which switch their settings around all the time, no?
>>
>>I can easily add this to the userspace tool to accept "pci_0000:01:00.0"
>>format and to map it internally to devlink index. No problem.
>
>I argue for this stable topology identifier to be the default. Especially if
>you add device info before the actual module is loaded (this is during
>initramfs, when udev cannot rename devlink names to stable ones), a user has
>to deal with pre-devlink-ids before rename and after. Do you have plans how
>to address that?

You can still access devlink using pci_addr using dl. I don't see a
problem.


>
>Current initramfs for stable interface names uses EUI48 based mac addresses
>most of the time and udev runs then after the pivot_root.
>
>The devlink names can easily be aliases in user space.

I don't want to store them anywhere. I just use "dl" tool and pass the
name there.


>
>Bye,
>Hannes
>
>
