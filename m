From: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
Subject: Re: [PATCH v2] fjes: Do not load fjes driver if system does not have
 extended socket device.
Date: Fri, 10 Mar 2017 12:09:02 -0500
Message-ID: <b61b605a-d248-261c-6543-243a38d6f97e@gmail.com>
References: <7a1a2dbc-99e0-06ba-2261-6e6382937486@gmail.com>
 <20170309.173519.1406243244628930968.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, izumi.taku@jp.fujitsu.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:34313 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755049AbdCJRJF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 12:09:05 -0500
Received: by mail-qk0-f193.google.com with SMTP id v125so28525610qkh.1
        for <netdev@vger.kernel.org>; Fri, 10 Mar 2017 09:09:04 -0800 (PST)
In-Reply-To: <20170309.173519.1406243244628930968.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 03/09/2017 08:35 PM, David Miller wrote:
> From: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
> Date: Wed, 8 Mar 2017 16:05:18 -0500
>
>> The fjes driver is used only by FUJITSU servers and almost of all
>> servers in the world never use it. But currently if ACPI PNP0C02
>> is defined in the ACPI table, the following message is always shown:
>>
>>  "FUJITSU Extended Socket Network Device Driver - version 1.2
>>   - Copyright (c) 2015 FUJITSU LIMITED"
>>
>> The message makes users confused because there is no reason that
>> the message is shown in other vendor servers.
>>
>> To avoid the confusion, the patch adds a check that the server
>> has a extended socket device or not.
>>
>> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>> CC: Taku Izumi <izumi.taku@jp.fujitsu.com>
>> ---
>> v2:
>> 	- Order local variable declarations from longest to shortest line
>
> This patch does not apply cleanly to the net tree.
>

Which tree did you apply the patch to?

The patch can apply to net-next tree with no conflicts as follows:

# git clone git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git
Cloning into 'net-next'...
remote: Counting objects: 5265118, done.
remote: Compressing objects: 100% (805485/805485), done.
Receiving objects: 100% (5265118/5265118), 910.11 MiB | 23.42 MiB/s, done.
remote: Total 5265118 (delta 4419240), reused 5264459 (delta 4418809)
Resolving deltas: 100% (4419240/4419240), done.
Checking out files: 100% (58005/58005), done.
# head -n 30 fjes.patch
Subject: [PATCH v2] fjes: Do not load fjes driver if system does not have extended socket device.
Date: Wed, 8 Mar 2017 16:05:18 -0500
From: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
To: netdev@vger.kernel.org
CC: David Miller <davem@davemloft.net>, izumi.taku@jp.fujitsu.com

The fjes driver is used only by FUJITSU servers and almost of all
servers in the world never use it. But currently if ACPI PNP0C02
is defined in the ACPI table, the following message is always shown:

  "FUJITSU Extended Socket Network Device Driver - version 1.2
   - Copyright (c) 2015 FUJITSU LIMITED"

The message makes users confused because there is no reason that
the message is shown in other vendor servers.

To avoid the confusion, the patch adds a check that the server
has a extended socket device or not.

Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
CC: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
v2:
	- Order local variable declarations from longest to shortest line

  drivers/net/fjes/fjes_main.c | 52 +++++++++++++++++++++++++++++++++++++++-----
  1 file changed, 47 insertions(+), 5 deletions(-)

diff --git a/drivers/net/fjes/fjes_main.c b/drivers/net/fjes/fjes_main.c
index b77e4ecf..a57c2cb 100644
# cd net-next/
# git am ../fjes.patch
Applying: fjes: Do not load fjes driver if system does not have extended socket device.
#


Thanks,
Yasuaki Ishimatsu
