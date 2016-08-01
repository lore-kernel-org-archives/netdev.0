From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [PATCH net-next 2/3] bna: change type of bna_id to atomic_t
Date: Mon, 1 Aug 2016 17:11:00 +0200
Message-ID: <345d713a-8399-b1ff-718a-ccf4547ecd4f@redhat.com>
References: <1469814778-23186-1-git-send-email-ivecera@redhat.com>
 <1469814778-23186-3-git-send-email-ivecera@redhat.com>
 <063D6719AE5E284EB5DD2968C1650D6D5F50672B@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "rasesh.mody@qlogic.com" <rasesh.mody@qlogic.com>
To: David Laight <David.Laight@ACULAB.COM>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58516 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752244AbcHAPLo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Aug 2016 11:11:44 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D5F50672B@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1.8.2016 16:20, David Laight wrote:
> From: Ivan Vecera
>> Sent: 29 July 2016 18:53
>> Change type of bna_id to atomic_t. The bnad_list_mutex is used to prevent
>> a race when bna_id is incremented. After the change the mutex can be
>> removed in the next step.
> ...
>> -static u32 bna_id;
>> +static atomic_t bna_id;
> ...
>>  	bnad_lock_init(bnad);
>>  	bnad_add_to_list(bnad);
>> +	bnad->id = atomic_inc_return(&bna_id) - 1;
> ...
>
> Is the 'id' expected to be unique?
> Looks like they get reallocated after 2^32 allocates.
>
> 	David
>
>
I have just converted it to atomic type to eliminate mutex. The id is 
only used as parameter 'instance' for bfa_nw_flash_{update,read}_part(). 
There is no documentation in source code regarding this so this is a 
question to Qlogic.

Ivan
