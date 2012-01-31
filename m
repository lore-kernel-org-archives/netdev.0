From: Jiri Slaby <jslaby@suse.cz>
Subject: Re: network regression: cannot rename netdev twice
Date: Tue, 31 Jan 2012 12:00:36 +0100
Message-ID: <4F27C9D4.3040105@suse.cz>
References: <4F27120A.4040106@suse.cz> <CAPXgP12Sr2KzGJ9RA13QBOCkctb-z3O4+1uHOjANgMDDv2pxaQ@mail.gmail.com> <4F27C54F.1010107@suse.cz> <CAPXgP11=U_Y3LvJB2LRnXQ53y1WQQTqc0j1c7iva6ZXvF97wEw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Greg KH <greg@kroah.com>, LKML <linux-kernel@vger.kernel.org>,
	ML netdev <netdev@vger.kernel.org>
To: Kay Sievers <kay.sievers@vrfy.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAPXgP11=U_Y3LvJB2LRnXQ53y1WQQTqc0j1c7iva6ZXvF97wEw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/31/2012 11:52 AM, Kay Sievers wrote:
> On Tue, Jan 31, 2012 at 11:41, Jiri Slaby <jslaby@suse.cz> wrote:
>> On 01/30/2012 11:52 PM, Kay Sievers wrote:
>>> 2012/1/30 Jiri Slaby <jslaby@suse.cz>:
>>>> I cannot boot properly with this commit:
>>>> commit 524b6c5b39b931311dfe5a2f5abae2f5c9731676
>>>> Author: Eric W. Biederman <ebiederm@xmission.com>
>>>> Date:   Sun Dec 18 20:09:31 2011 -0800
>>>>
>>>>    sysfs: Kill nlink counting.
>>>>
>>>> 1) network systemd rule doesn't start network
>>>
>>> What does that mean? What's a network systemd rule?
>>
>> Oh, perhaps you call it a service file, not rule file?
>>
>> Anyway this is a different bug. Revert of the patch above does not help.
> 
> Ok, fine. I checked too, and systemd does not play any silly games
> with link counts.
> 
>> The bug lays in the network layer. udev is unable to perform persistent
>> eth naming:
>> # ip link set eth0 name eth1    -- this one is OK
>> # ip link set eth1 name eth0
>> RTNETLINK answers: No such file or directory
> 
> Please make sure nothing tries to swap netif names in userspace. We
> have given up that approach, because it is far too fragile to
> temporary rename devices to be able to swap the names, and race
> against the loading of new kernel network drivers at the same time.
> 
> This might be a new kernel problem here, but in general that approach
> is just broken, we have have given up fiddling around here. Udev does
> not do that anymore, and also the code that currently *can* be used to
> do this, will be removed from udev in the future.
> 
> Network devices can only be renamed to a namespace that isn't ethX,
> and which does not race against kernel names.

I have two eth interfaces. The one on the motherboard is named eth0, an
added PCI card is eth1. But kernel enumerates them in the opposite order.

So udev does this sequence:
eth1 -> rename3
eth0 -> eth1
rename3 -> eth0

How it can do it differently? (This is openSUSE factory.)

> Does is work, if you rename the devices to something else than ethX?

Negative:
# ip link set eth0 name krtek
# ip link set krtek name jezek
RTNETLINK answers: No such file or directory

thanks,
-- 
js
suse labs
