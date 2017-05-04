From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH] iproute2: hide devices starting with period by default
Date: Thu, 4 May 2017 10:37:39 -0600
Message-ID: <4bbb7a19-1b0b-8c9a-7e74-82ee146cf48c@gmail.com>
References: <027775d1-ef98-deda-1f8d-bb058d1e4c2f@cumulusnetworks.com>
 <20170223163035.0a49f04d@xeon-e3>
 <13cec1c2-88f4-e61d-02ee-dc01ccee7281@cumulusnetworks.com>
 <20170223.221257.795227595252531962.davem@redhat.com>
 <0a8e1cf0-9f30-2356-5168-a97abb86d5c2@cumulusnetworks.com>
 <0635d3bb-0d8d-7ab6-fb53-4d84f979a023@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@redhat.com>, stephen@networkplumber.org,
        netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:36411 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754511AbdEDQhn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 12:37:43 -0400
Received: by mail-pg0-f44.google.com with SMTP id q4so3562387pga.3
        for <netdev@vger.kernel.org>; Thu, 04 May 2017 09:37:42 -0700 (PDT)
In-Reply-To: <0635d3bb-0d8d-7ab6-fb53-4d84f979a023@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/4/17 9:15 AM, Nicolas Dichtel wrote:
> Le 24/02/2017 à 16:52, David Ahern a écrit :
>> On 2/23/17 8:12 PM, David Miller wrote:
>>> This really need to be a fundamental facility, so that it transparently
>>> works for NetworkManager, router daemons, everything.  Not just iproute2
>>> and "ls".
>>
>> I'll rebase my patch and send out as RFC.
>>
> David, did you finally send those patches?
> 

No, but for a few reasons.

It is easy to hide devices in a dump:

https://github.com/dsahern/linux/commit/48a80a00eac284e58bae04af10a5a932dd7aee00


But I think those devices should also not exist in sysfs or procfs which
overlaps what I would like to see for lightweight netdevices:

https://github.com/dsahern/linux/commit/70574be699cf252e77f71e3df11192438689f976


and to be complete, hidden devices should not be allowed to have a
network address or transmit packets which is the L2 only intent from
Florian:
    https://www.spinics.net/lists/netdev/msg340808.html
