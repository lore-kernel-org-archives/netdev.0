From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [PATCH] SIW: User interface
Date: Tue, 05 Oct 2010 09:32:53 -0500
Message-ID: <4CAB3715.60906@opengridcomputing.com>
References: <1286261647-5139-1-git-send-email-bmt@zurich.ibm.com> <4CAB337E.1040205@opengridcomputing.com> <OF07B553EF.B746D69E-ONC12577B3.004EAD6A-C12577B3.004F92B0@ch.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org
To: Bernard Metzler <BMT@zurich.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:45279 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751142Ab0JEOc6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 10:32:58 -0400
In-Reply-To: <OF07B553EF.B746D69E-ONC12577B3.004EAD6A-C12577B3.004F92B0@ch.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/05/2010 09:29 AM, Bernard Metzler wrote:
> Steve Wise<swise@opengridcomputing.com>  wrote on 10/05/2010 04:17:34 PM:
>
>    
>> Steve Wise<swise@opengridcomputing.com>
>> 10/05/2010 04:17 PM
>>
>> To
>>
>> Bernard Metzler<bmt@zurich.ibm.com>
>>
>> cc
>>
>> netdev@vger.kernel.org, linux-rdma@vger.kernel.org
>>
>> Subject
>>
>> Re: [PATCH] SIW: User interface
>>
>> On 10/05/2010 01:54 AM, Bernard Metzler wrote:
>>
>>
>> <snip>
>>
>>      
>>> +
>>> +/*
>>> + * siw_post_send()
>>> + *
>>> + * Post a list of S-WR's to a SQ.
>>> + *
>>> + * @ofa_qp:   OFA QP contained in siw QP
>>> + * @wr:      Null terminated list of user WR's
>>> + * @bad_wr:   Points to failing WR in case of synchronous failure.
>>> + */
>>> +int siw_post_send(struct ib_qp *ofa_qp, struct ib_send_wr *wr,
>>> +        struct ib_send_wr **bad_wr)
>>> +{
>>> +   struct siw_wqe   *wqe = NULL;
>>> +   struct siw_qp   *qp = siw_qp_ofa2siw(ofa_qp);
>>> +
>>> +   unsigned long flags;
>>> +   int rv = 0;
>>> +
>>> +   dprint(DBG_WR|DBG_TX, "(QP%d): state=%d\n",
>>> +      QP_ID(qp), qp->attrs.state);
>>> +
>>> +   /*
>>> +    * Acquire QP state lock for reading. The idea is that a
>>> +    * user cannot move the QP out of RTS during TX/RX processing.
>>> +    */
>>> +   down_read(&qp->state_lock);
>>> +
>>>
>>>        
>> I don't think you can use a rw_semaphore here because it potentially can
>>      
>    
>> block.  You cannot block/sleep in the post_send/post_recv (and some
>> other) RDMA provider functions.  See
>> Documentation/infiniband/core_locking.txt.
>>
>>
>>      
> ah, ok.
> with that, a down_read_trylock() would solve the issue...?
> given the limited set of errno values - what would you suggest
> as a meaningful return value? EBUSY, EINVAL, ...?
>
>    

I think it is expected that you should implement this without requiring 
the blocking semaphore.  Returning an error will cause the application 
to bail.


Steve.
