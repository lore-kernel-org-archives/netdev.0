From: Jarod Wilson <jarod@redhat.com>
Subject: Re: bond procfs hw addr prints
Date: Mon, 13 Mar 2017 22:06:06 -0400
Message-ID: <8aa4aff4-e1b3-83b5-f453-c6485f540705@redhat.com>
References: <597da6f1-c0fc-ae23-94d1-d0fb3abb3176@redhat.com>
 <10202.1489451284@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33840 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752044AbdCNCGG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 13 Mar 2017 22:06:06 -0400
In-Reply-To: <10202.1489451284@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-03-13 8:28 PM, Jay Vosburgh wrote:
> Jarod Wilson <jarod@redhat.com> wrote:
>
>> I've got a bug report for someone using a Intel OPA devices in a bond, and
>> it appears these devices have a hardware address length of 20, opposed to
>> the typical 6 on ethernet. When they dump /proc/net/bonding/bondX, it only
>> prints the first 6 of the address, per %pM and mac_address_string(), while
>> sysfs for the interface does print the right thing, since it uses
>> sysfs_print_mac(), which takes a length argument.
>
> 	This (20 octet MAC length) is true for any Infiniband device.
>
>> So the question is... What's the best route to take here? Expand %pM to
>> support variable length hardware addresses? Use sysfs_* in procfs?
>> Reinvent the wheel? Nothing I've tinkered with just yet feels very clean,
>> on top of not actually working yet. :)
>
> 	sysfs_format_mac (not _print_mac) uses "%*phC", len, addr in its
> format string.  Perhaps that format would be a better choice than %pM
> for this case?

Ah, I'd failed to fully grasp how %phC worked, had actually tried it w/o 
the * in there, and only the first char of the addr was printing. 
Working on an updated version that uses %*phC properly, which does look 
like the way to go here. (Didn't help that I was also looking at an 
older codebase that didn't have the sysfs_format_mac de-duplication). 
I'll try to have a tested patch in flight tomorrow.

-- 
Jarod Wilson
jarod@redhat.com
