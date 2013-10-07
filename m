From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] net: Separate the close_list and the unreg_list v2
Date: Mon, 07 Oct 2013 15:45:36 -0700
Message-ID: <87d2ngvgxb.fsf@xmission.com>
References: <5250c0b6.45dc420a.738b.6a58@mx.google.com>
	<87txgv9ltu.fsf@xmission.com>
	<20131007.152238.779958484281422820.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: fruggeri@aristanetworks.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:33700 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751475Ab3JGWpn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Oct 2013 18:45:43 -0400
In-Reply-To: <20131007.152238.779958484281422820.davem@davemloft.net> (David
	Miller's message of "Mon, 07 Oct 2013 15:22:38 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Sat, 05 Oct 2013 19:26:05 -0700
>
>> 
>> Separate the unreg_list and the close_list in dev_close_many preventing
>> dev_close_many from permuting the unreg_list.  The permutations of the
>> unreg_list have resulted in cases where the loopback device is accessed
>> it has been freed in code such as dst_ifdown.  Resulting in subtle memory
>> corruption.
>> 
>> This is the second bug from sharing the storage between the close_list
>> and the unreg_list.  The issues that crop up with sharing are
>> apparently too subtle to show up in normal testing or usage, so let's
>> forget about being clever and use two separate lists.
>> 
>> v2: Make all callers pass in a close_list to dev_close_many
>> 
>> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
>> ---
>> 
>> Sending the complete diff because this version is actually more
>> readable and more obviously correct.
>
> I'll apply this, thanks Eric.

Thanks.  It is good to see this getting sorted out.

Eric
