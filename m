From: Prarit Bhargava <prarit@redhat.com>
Subject: Re: [PATCH] net, mellanox mlx4 Fix compile warnings
Date: Mon, 16 Sep 2013 08:14:50 -0400
Message-ID: <5236F63A.9000202@redhat.com>
References: <1379075438-20240-1-git-send-email-prarit@redhat.com><CAJZOPZLt8G8MsPxiRNySex=izThR74bXcnWTmWB2wjPys09_ig@mail.gmail.com> <20130915091400.49f90bc4@jpm-OptiPlex-GX620> <AE90C24D6B3A694183C094C60CF0A2F6026B733A@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <or.gerlitz@gmail.com>, netdev@vger.kernel.org,
	Doug Ledford <dledford@redhat.com>,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37733 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756257Ab3IPMPk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Sep 2013 08:15:40 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B733A@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 09/16/2013 04:59 AM, David Laight wrote:
>> On Sat, 14 Sep 2013 22:10:19 +0300
>> Or Gerlitz <or.gerlitz@gmail.com> wrote:
>>
>>>> +       struct res_cq *uninitialized_var(cq);
>>>>
>>>>         err = cq_res_start_move_to(dev, slave, cqn,
>>>> RES_CQ_ALLOCATED, &cq);
>>
>> I have no objection. However, I don't know if the compiler is being too
>> clever here or too stupid.  The cq variable is initialized in
>> cq_res_start_move_to(), but the compiler is ignoring this -- or maybe
>> it is simply not assuming that cq will in fact be
>> initialized by the called procedure?
> 
> Possibly cq_res_start_move_to() got inlined - and the analysis
> of the inlined code found a path where it wasn't initialised.
> 
> Most likely one of the paths where the return value is non-zero.
> 
>> In any event, this change cannot hurt.
> 
> It could hide a real 'used but not initialised' error later on...

Hi David,

I certainly don't profess to know the code better than you do of course, but in
terms of risk we're no better in than the original code here, and it seems that
other places in the kernel the resolution has been to either init to NULL or
wrap with uninitialized_var()...

P.
