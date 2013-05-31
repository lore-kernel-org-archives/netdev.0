From: Alan Robertson <alanr@unix.sh>
Subject: Re: [PATCH net] rtnetlink: ndo_dflt_fdb_del() never works
Date: Fri, 31 May 2013 13:59:07 -0600
Message-ID: <51A9010B.6060307@unix.sh>
References: <1369951315-14742-1-git-send-email-alanr@unix.sh> <20130531.014607.358769391044586124.davem@davemloft.net> <51A8D342.2010802@unix.sh> <51A8D9D3.3020601@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	davem@gavemloft.net, kuznet@ms2.inr.ac.ru
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from c60.cesmail.net ([216.154.195.49]:52486 "EHLO c60.cesmail.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754217Ab3EaT7K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 May 2013 15:59:10 -0400
In-Reply-To: <51A8D9D3.3020601@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/31/2013 11:11 AM, Vlad Yasevich wrote:
> On 05/31/2013 12:43 PM, Alan Robertson wrote:
>> On 05/31/2013 02:46 AM, David Miller wrote:
>>> From: Alan Robertson <alanr@unix.sh>
>>> Date: Thu, 30 May 2013 16:01:55 -0600
>>>
>>>> ndo_dflt_fdb_del is checking for a condition which is opposite that
>>>> which ndo_dflt_fdb_add enforces.  ndo_dflt_fdb_add declares an error
>>>> if (ndm->ndm_state && !(ndm->ndm_state) & NUD_PERMANENT)) - that
>>>> is, if the
>>>> entry is static.  This is consistent with the failure error message.
>>>>
>>>> On the other hand, ndo_dflt_del() declares an error
>>>> if (ndm_state & NUD_PERMANENT) - which is inconsistent with the add
>>>> precondition, and inconsistent with its failure message text.
>>>> As it is now, you can't delete any entry which add allows to be
>>>> added -
>>>> so entry deletion always fails.
>>>>
>>>> Signed-off-by: Alan Robertson <alanr@unix.sh>
>>> What about the ->ndm_state part of the add() test?  Why not include
>>> that in the del() check?
>> I had three different thoughts about this:
>>    1) Replicated the add check in the delete
>>    2) Do what I did - make it where you can only delete those really
>> marked as static
>>    3) Eliminate all delete checks
>>
>> The problem is -- I'm not sure why the ndm->ndm_state check is in there
>> -- I don't know how to make that condition occur.  It has the feel of a
>> check to be made before things are fully initialized - or maybe even
>> just leftover cruft.
>>
>
> The test  is there to support simultaneous master and self operations.
> The operation on a master may not always require a NUD_PERMANENT state
> (ex: bridge) and we don't want to perform self operations in that
> instance.
>
>> You could make the argument that option (3) is the best -- if it's been
>> added successfully, you ought to be able to delete it.
>
> Hmm..  _del() always deletes and flags/states don't matter much
> generally.  I agree that the check isn't really needed as it isn't
> really protecting anything.

So is that what folks want me to do?

-- 
    Alan Robertson <alanr@unix.sh> - @OSSAlanR

"Openness is the foundation and preservative of friendship...  Let me claim from you at all times your undisguised opinions." - William Wilberforce
