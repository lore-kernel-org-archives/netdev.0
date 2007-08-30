From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [Lksctp-developers] SCTP: Fix dead loop while received unexpected
 chunk with length set to zero
Date: Thu, 30 Aug 2007 09:45:22 -0400
Message-ID: <46D6C9F2.5020702@hp.com>
References: <46D223A0.3080604@cn.fujitsu.com> <46D44630.8070802@hp.com> <46D51F91.90101@cn.fujitsu.com> <46D5901C.3010802@hp.com> <46D658B8.8070801@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: lksctp-developers@lists.sourceforge.net, netdev@vger.kernel.org
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:50857 "EHLO atlrel6.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751131AbXH3Npt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Aug 2007 09:45:49 -0400
In-Reply-To: <46D658B8.8070801@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wei Yongjun wrote:
> Vlad Yasevich wrote:
>> Wei Yongjun wrote:
>>  
>>> Vlad Yasevich wrote:
>>>    
>>>> NACK
>>>>
>>>> Section 8.4:
>>>>
>>>>    An SCTP packet is called an "out of the blue" (OOTB) packet if it is
>>>>    correctly formed (i.e., passed the receiver's CRC32c check; see
>>>>    Section 6.8), but the receiver is not able to identify the
>>>>    association to which this packet belongs.
>>>>
>>>>
>>>> I would argue that the packet is not correctly formed in this case
>>>> and deserves a protocol violation ABORT in return.
>>>>
>>>> -vlad
>>>>         
>>> As your comment, patch has been changed.
>>> Patch has been split to two, one is resolve this dead loop problem in
>>> this mail.
>>> And the other is come in another mail to discard partial chunk which
>>> chunk length is set to zero.
>>>     
>>
>>
>> I am starting to question the entire OOTB packet handling.  There are way
>> too many function that do almost the same thing and all handle OOTB a
>> little
>> different.
>>
>> sctp_sf_do_9_2_reshutack() is also called during sctp_sf_do_dupcook_a()
>> processing, so checking for INIT chunk is wrong.  Checking for just the
>> chunkhdr_t should be enough.
>>   
> This has been changed.
>> sctp_sf_tabort_8_4_8 is used directly as well (not just through the state
>> machine).  Not sure if the header verification is appropriate.
>>   
> It is needed. Because sctp_sf_tabort_8_4_8() is called to handle OOTB
> packet before check the header length.

But now we are doing the same thing twice (and this is not the only place).
I know I am being really picky here, but I am starting to thing the ootb handling\
is a mess and I really don't want to add to the mess.

Until I (or someone else) prove that it's not a mess or fix it, I am going
to hold off on these patches.

Feel free to go through the spec and fix all the OOTB handling.

Thanks
-vlad

