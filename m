From: Jiri Slaby <jslaby@suse.cz>
Subject: network regression: cannot rename netdev twice
Date: Tue, 31 Jan 2012 11:41:19 +0100
Message-ID: <4F27C54F.1010107@suse.cz>
References: <4F27120A.4040106@suse.cz> <CAPXgP12Sr2KzGJ9RA13QBOCkctb-z3O4+1uHOjANgMDDv2pxaQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Greg KH <greg@kroah.com>, LKML <linux-kernel@vger.kernel.org>,
	ML netdev <netdev@vger.kernel.org>
To: Kay Sievers <kay.sievers@vrfy.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAPXgP12Sr2KzGJ9RA13QBOCkctb-z3O4+1uHOjANgMDDv2pxaQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/30/2012 11:52 PM, Kay Sievers wrote:
> 2012/1/30 Jiri Slaby <jslaby@suse.cz>:
>> I cannot boot properly with this commit:
>> commit 524b6c5b39b931311dfe5a2f5abae2f5c9731676
>> Author: Eric W. Biederman <ebiederm@xmission.com>
>> Date:   Sun Dec 18 20:09:31 2011 -0800
>>
>>    sysfs: Kill nlink counting.
>>
>>
>> 1) network systemd rule doesn't start network
> 
> What does that mean? What's a network systemd rule?

Oh, perhaps you call it a service file, not rule file?

Anyway this is a different bug. Revert of the patch above does not help.

The bug lays in the network layer. udev is unable to perform persistent
eth naming:
# ip link set eth0 name eth1    -- this one is OK
# ip link set eth1 name eth0
RTNETLINK answers: No such file or directory

thanks,
-- 
js
suse labs
