From: Keiichi KII <k-keiichi@bx.jp.nec.com>
Subject: Re: [RFC][PATCH -mm take2 3/5] add interface for netconsole using
 sysfs
Date: Wed, 10 Jan 2007 19:33:41 +0900
Message-ID: <45A4C105.3000509@bx.jp.nec.com>
References: <4590AE00.5040102@bx.jp.nec.com> <4590B365.8010707@bx.jp.nec.com> <4595F630.70705@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: mpm@selenic.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO201.gate.nec.co.jp ([202.32.8.193]:50053 "EHLO
	tyo201.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964833AbXAJKeE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jan 2007 05:34:04 -0500
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <4595F630.70705@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> create a sysfs entry for netconsole in /sys/class/misc.
>> This entry has elements related to netconsole as follows.
>> You can change configuration of netconsole(writable attributes such as IP
>> address, port number and so on) and check current configuration of netconsole.
>>
>> -+- /sys/class/misc/
>>  |-+- netconsole/
>>    |-+- port1/
>>    | |--- id          [r--r--r--]  unique port id
>>    | |--- remove      [-w-------]  if you write something to "remove",
>>    | |                             this port is removed.
>>   
> IMHO this kind of "magic side effect" is a misuse of sysfs. and would
> make proper locking
> impossible. How do you deal with the dangling reference to the
> netconsole object?

I manage the reference by using a list.
If you write something to "remove", 
firstly the port entry is removed from sysfs and then
the reference is removed from the list and a resource of the port is freed.

> f= open (... netconsole/port1/remove")
> write(f, "", 1)
> sleep(2)
> write(f, "", 1) .... this probably would crash...
> 
> 
> Maybe having a state variable/sysfs file so you could setup the port and
> turn it on/off with write.

You are right.
When I tested above program, my machine crashed.

I'm going to rethink the interface for netconsole.

Thanks for your comments.
-- 
Keiichi KII
NEC Corporation OSS Promotion Center
E-mail: k-keiichi@bx.jp.nec.com



