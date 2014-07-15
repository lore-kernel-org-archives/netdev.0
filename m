From: Veaceslav Falico <vfalico@gmail.com>
Subject: Re: [PATCH net-next 2/2] bonding: make hard-coded defines
 configurable at build
Date: Tue, 15 Jul 2014 18:18:02 +0200
Message-ID: <20140715161802.GC5225@mikrodark.usersys.redhat.com>
References: <1405419341-31510-1-git-send-email-vfalico@gmail.com>
 <1405419341-31510-3-git-send-email-vfalico@gmail.com>
 <CAADnVQJCNJVTBFkinNzo=1mSWEBhif3dOVnVvuievJxijtNb7w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:49801 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751279AbaGOQVB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 12:21:01 -0400
Received: by mail-wg0-f49.google.com with SMTP id k14so5237625wgh.32
        for <netdev@vger.kernel.org>; Tue, 15 Jul 2014 09:21:00 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAADnVQJCNJVTBFkinNzo=1mSWEBhif3dOVnVvuievJxijtNb7w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 15, 2014 at 08:48:01AM -0700, Alexei Starovoitov wrote:
>On Tue, Jul 15, 2014 at 3:15 AM, Veaceslav Falico <vfalico@gmail.com> wrote:
>> CC: Jay Vosburgh <j.vosburgh@gmail.com>
>> CC: Andy Gospodarek <andy@greyhouse.net>
>> Signed-off-by: Veaceslav Falico <vfalico@gmail.com>
>> ---
>>  drivers/net/bonding/Kconfig   | 16 ++++++++++++++++
>>  drivers/net/bonding/bonding.h |  6 +++---
>>  2 files changed, 19 insertions(+), 3 deletions(-)
>>
>> diff --git a/drivers/net/bonding/Kconfig b/drivers/net/bonding/Kconfig
>> index 7b1a0fa..28fb3af 100644
>> --- a/drivers/net/bonding/Kconfig
>> +++ b/drivers/net/bonding/Kconfig
>> @@ -15,3 +15,19 @@ menuconfig BONDING
>>
>>           To compile this driver as a module, choose M here: the module
>>           will be called bonding.
>> +
>> +if BONDING
>> +
>> +config BOND_MAX_VLAN_ENCAP
>> +       int "Maximum number of stacked vlans on top of bonding"
>> +       default "2"
>> +
>
>I don't think we should allow changing these defaults so easily.
>Not a single HW supports 3 vlan tags. There is no standard for it either.
>Why you would ever change this?

There have been discussions about vlan nestings for bonding, and the
outcome was that more than 2 are possible. Also, iirc, no standard limits
it to only 2.

I'm not sure about the "changing these defaults so easily" - this default
limits the depth at which we traverse the vlan tree when sending packets in
arp monitor, so it has no actual impact on the work of vlans themselves.

>
>> +config BOND_MAX_ARP_TARGETS
>> +       int "Maximum number of ip targets arp monitor supports"
>> +       default "16"
>> +
>> +config BOND_DEFAULT_MIIMON
>> +       int "Default miimon monitoring frequency in milliseconds"
>> +       default "100"
>
>or this?

This is the default value chosen when there's no configuration/illegal
configuration, so it's a good point to configure it at build.

>imo existing built-ins are fine and adding extra knobs just scary.
>Users will have different numbers here and somebody would
>need to make sure that all different defaults still work.
>We should be minimizing the number of knobs instead.

These defaults are scalable by their nature, and there are people
maintaining their own patches to change them. So making them available to
be configured at compile time is a good thing to do, I think.
