From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC][PATCH 1/1] cxgb3i: cxgb3 iSCSI initiator
Date: Wed, 13 Aug 2008 20:26:51 -0500
Message-ID: <48A389DB.9050002@opengridcomputing.com>
References: <ada3al8k3l5.fsf@cisco.com>	<20080813.150831.193391799.davem@davemloft.net>	<adatzdoiklo.fsf@cisco.com> <20080813.161237.10205799.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, rick.jones2@hp.com, jgarzik@pobox.com,
	swise@opengridcomputing.com, divy@chelsio.com, kxie@chelsio.com,
	netdev@vger.kernel.org, open-iscsi@googlegroups.com,
	michaelc@cs.wisc.edu, daisyc@us.ibm.com, wenxiong@us.ibm.com,
	bhua@us.ibm.com, dm@chelsio.com, leedom@chelsio.com,
	linux-scsi@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20080813.161237.10205799.davem@davemloft.net>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Roland Dreier <rdreier@cisco.com>
> Date: Wed, 13 Aug 2008 16:03:15 -0700
>
>   
>> OK, I admit you could make something work -- add hooks for the low-level
>> driver to ask the iSCSI initiator where PDU boundaries are so it can
>> resync when something is evicted from the flow cache, have the initiator
>> format its tags in a special way to encode placement data, etc, etc.
>> The scheme does bring to mind Alan's earlier comment about pigs and
>> propulsion, though.
>>     
>
> There would need to be _NO_ hooks into the iSCSI initiator at all.
>
> The card would land the block I/O data onto the necessary page boundaries
> and the iSCSI code would just be able to thus use the pages directly
> and as-is.
>
> It would look perfectly like normal TCP receive traffic.  No hooks,
> no special cases, nothing like that.
>
>   
>> In any case, as I said in the part of my email that you snipped, the
>> real issue is not designing hypothetical hardware, but deciding how to
>> support the Chelsio, Broadcom, etc hardware that exists today.
>>     
>
> The same like we support TOE hardware that exists today.  That is, we
> don't.
>
>   
Is there any chance your could discuss exactly how a stateless adapter 
can determine if a network segment
is in-order, next expected, minus productive ack, paws compliant, etc... 
without TCP state?

I get how you can optimize "flows", but "flows" are a fancy name for a 
key (typically the four-tuple) that looks into a TCAM  to get the 
"information" necessary to do header prediction.

Can you explain how this "information" somehow doesn't qualify as 
"state". Doesn't the next expected sequence number at the very least 
need to be updated? una? etc...?

Could you also include the "non-state-full" information necessary to do 
iSCSI header digest validation, data placement, and marker removal? 

Thanks,
Tom
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>   

