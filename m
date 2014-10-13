From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Re: [PATCH stable 3.2 3.4] ipv4: disable bh while doing route gc
Date: Mon, 13 Oct 2014 13:58:31 -0300
Message-ID: <543C04B7.1040005@redhat.com>
References: <6c3d6eca5d6a15c01393b010f2116bd169477c5a.1413215324.git.mleitner@redhat.com> <20141013.125225.1129718741415025861.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61479 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754486AbaJMQ7O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Oct 2014 12:59:14 -0400
In-Reply-To: <20141013.125225.1129718741415025861.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13-10-2014 13:52, David Miller wrote:
> From: Marcelo Ricardo Leitner <mleitner@redhat.com>
> Date: Mon, 13 Oct 2014 13:20:38 -0300
>
>> Further tests revealed that after moving the garbage collector to a work
>> queue and protecting it with a spinlock may leave the system prone to
>> soft lockups if bottom half gets very busy.
>>
>> It was reproced with a set of firewall rules that REJECTed packets. If
>> the NIC bottom half handler ends up running on the same CPU that is
>> running the garbage collector on a very large cache, the garbage
>> collector will not be able to do its job due to the amount of work
>> needed for handling the REJECTs and also won't reschedule.
>>
>> The fix is to disable bottom half during the garbage collecting, as it
>> already was in the first place (most calls to it came from softirqs).
>>
>> Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
>> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>
> Please add my:
>
> Acked-by: David S. Miller <davem@davemloft.net>
>
> and submit this directly to -stable, thanks.

Will do. Thanks.

Marcelo
