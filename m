From: Warren Turkal <wt@penguintechs.org>
Subject: Re: dummy ethernet devices and sysfs
Date: Wed, 13 Jan 2016 14:54:15 -0800
Message-ID: <CAB_jBhi7Ko659axT8oZEBB6z5Vm6tLYF35eBCO6ujubNkgp_6A@mail.gmail.com>
References: <CAB_jBhhyNLeYSuOQUXPTtU3LaVdjXtD=jS0kuvMckDjyOz1Xzg@mail.gmail.com>
 <20160113121609.139af5a2@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:34452 "EHLO
	mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750913AbcAMWyf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2016 17:54:35 -0500
Received: by mail-io0-f170.google.com with SMTP id 1so387709186ion.1
        for <netdev@vger.kernel.org>; Wed, 13 Jan 2016 14:54:35 -0800 (PST)
In-Reply-To: <20160113121609.139af5a2@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 13, 2016 at 12:16 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> If you look carefully at the /sys/class/net/wlp2s0/device/ you will
> see it is a symlink to the underlying /sys directory for the hardware (PCI)
> device.  Since dummy (and other virtual interfaces) have no hardware,
> there is no symlink.

What's the right way for one find the module that caused dummy0 to exist?

wt

On Wed, Jan 13, 2016 at 12:16 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Wed, 13 Jan 2016 11:58:01 -0800
> Warren Turkal <wt@penguintechs.org> wrote:
>
>> Hi,
>>
>> I was looking through sysfs today, and something interesting jumped
>> out at me after I loaded the dummy module.
>>
>> This directory exists: /sys/class/net/wlp2s0/device/
>>
>> This directory does not: /sys/class/net/dummy0/device/
>>
>> I can find the module that is providing the wlp2s0 device with the following:
>> $ ls /sys/class/net/wlp2s0/device/driver/module/drivers/
>> pci:iwlwifi
>>
>> Shouldn't dummy have something similar so that one can figure out
>> which module is providing the dummy0 device?
>>
>> FWIW, I am running the latest Ubuntu 15.10 kernel (4.2.0-23-generic).
>>
>> Thanks,
>> wt
>
> If you look carefully at the /sys/class/net/wlp2s0/device/ you will
> see it is a symlink to the underlying /sys directory for the hardware (PCI)
> device.  Since dummy (and other virtual interfaces) have no hardware,
> there is no symlink.
