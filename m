From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next 3/3] packet: use percpu mmap tx frame pending
 refcount
Date: Mon, 13 Jan 2014 13:57:45 +0100
Message-ID: <52D3E2C9.5060706@redhat.com>
References: <1389543768-20234-1-git-send-email-dborkman@redhat.com> <1389543768-20234-4-git-send-email-dborkman@redhat.com> <CAHA+R7NnaxXgOGW=jTEGkeMByO7wXVr9bGR-J9rLzwL4ne52bA@mail.gmail.com> <52D3CBA5.4080301@redhat.com> <063D6719AE5E284EB5DD2968C1650D6D459065@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <cwang@twopensource.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50623 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751259AbaAMM55 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Jan 2014 07:57:57 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D459065@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/13/2014 12:58 PM, David Laight wrote:
> From: Daniel Borkmann
> ...
>> But I think I found a different problem with this idea. It could
>> happen with net devices as well, but probably less likely as there
>> might be a better distribution of hold/puts among CPUs. However,
>> for TX_RING, if we pin the process to a particular CPU, and since
>> the destructor is invoked through ksoftirqd, we could end up with
>> a misbalance and if the process runs long enough eventually
>> overflow for one particular CPU. We could work around that, but I
>> think it's not worth the effort.
>
> The sum will be 'correct' when summed across all the cpu even if
> one of the values has wrapped - provided all the arithmetic is
> unsigned and the variables all the same type.

You are right, sorry, too much coffee this morning, I missed that.

Then, imho, this should work.
