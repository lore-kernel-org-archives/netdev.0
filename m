From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: Use CAP_NET_ADMIN and alias netdev-nlmon instead
Date: Sat, 9 Aug 2014 13:23:24 -0700
Message-ID: <09B6E85F-9B01-435B-B18B-71730DBD450D@holtmann.org>
References: <7B1A5F4E-7DCD-4054-9E8C-E5511AF64CE3@holtmann.org> <53E67742.9080405@redhat.com>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:44758 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751055AbaHIUW5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Aug 2014 16:22:57 -0400
In-Reply-To: <53E67742.9080405@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Daniel,

>> so I am running this command sequence:
>> 
>> 	ip link add name nlmon type nlmon
>> 	ip link set dev nlmon up
>> 
>> With that I get this message in dmesg:
>> 
>> Loading kernel module for a network device with CAP_SYS_MODULE (deprecated).
> > Use CAP_NET_ADMIN and alias netdev-nlmon instead.
>> 
>> The kernel section producing this is dev_load() from net/core/dev_ioctl.c:
>> 
>>         no_module = !dev;
>>         if (no_module && capable(CAP_NET_ADMIN))
>>                 no_module = request_module("netdev-%s", name);
>>         if (no_module && capable(CAP_SYS_MODULE)) {
>>                 if (!request_module("%s", name))
>>                         pr_warn("Loading kernel module for a network device with CAP_SYS_MODULE (deprecated).  Use CAP_NET_ADMIN and alias netdev-%s instead.\n",
>>                                 name);
>>         }
>> 
>> Since I am explicitly giving the name from userspace, I have no idea why the
> > kernel bugs me in providing netdev-nlmon alias. It makes no sense to me. What
> > is the reasoning behind this?
> 
> Could it just be that your process doesn't have CAP_NET_ADMIN set
> but CAP_SYS_MODULE instead thus triggering this pr_warn()?
> 
> grep Cap /proc/$$/status ?
> 
> Hm, I don't think this is nlmon related, above works fine on my side.

so I have not nlmon.ko loaded or compiled into the kernel. This means the ip command will trigger the autoloading. Command is either run with sudo or as root. So this is not a capability issue.

I think this is just a wrong check when handling loading of modules. I still do not understand how a netdev-%s alias makes any sense. Or even trying to load module nlmon.ko since I created interface nlmon.

The real module loading should also be done in the type and not the name.

Regards

Marcel
