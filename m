From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net] Revert "net: sctp: Fix a_rwnd/rwnd management to
 reflect real state of the receiver's buffer"
Date: Wed, 16 Apr 2014 09:32:23 -0400
Message-ID: <534E8667.5000503@gmail.com>
References: <1397504717-19566-1-git-send-email-dborkman@redhat.com> <534C3DC2.9070604@gmail.com> <534E29D4.60100@nsn.com> <CAE8XmWqgcNAHcKnzdUamQ0T+NP27GKSiRv37JEHSQW-=1Fu=2w@mail.gmail.com> <534E473E.20303@nsn.com> <534E6FC4.8020706@nsn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>
To: Matija Glavinic Pecotic <matija.glavinic-pecotic.ext@nsn.com>,
	Alexander Sverdlin <alexander.sverdlin@nsn.com>,
	ext Dongsheng Song <dongsheng.song@gmail.com>,
	Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f52.google.com ([209.85.192.52]:55279 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161111AbaDPNc1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2014 09:32:27 -0400
In-Reply-To: <534E6FC4.8020706@nsn.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/16/2014 07:55 AM, Matija Glavinic Pecotic wrote:
> Hello,
> 
> On 16.04.2014 11:02, Alexander Sverdlin wrote:
>> Hi Dongsheng!
>>
>> On 16/04/14 10:39, ext Dongsheng Song wrote:
>>> >From my testing, netperf throughput from 600 Mbit/s drop to 6 Mbit/s,
>>> the penalty is 99 %.
>>
>> The question was, do you see this as a problem of the new rwnd algorithm?
>> If yes, how exactly? The algorithm actually has no preference to any
>> amount of data.
>> It was fine-tuned before to serve as congestion control algorithm, but
>> this should
>> be located elsewhere. Perhaps, indeed, a re-use of congestion control
>> modules from
>> TCP would be possible...
> 
> Its also worth to note that sctp specifies rfc2581 for congestion
> control. TCP obsoleted that one in favor of 5681.
> 
> @Vlad, after Alexanders comment, it seems to be that you were referring
> to performance penalty. At first, I understood you refer to some penalty
> in rwnd calculation against buffer/rwnd value/something else. Thats why
> I asked that.
> 
> What also might be is that we are hitting SWS. I remember us observing
> some scenarios in which SWS is broken, new rwnd might have triggered it
> fully.
> 
> In any case, after some thought in the meantime, I'm pretty much sure
> that we need to improve congestion control and that new rwnd calculation
> is correct approach.

I am not sure where congestion control is broken.  It might be nice to
add a periodic SCTP_STATUS call to netperf/iperf to see what the state
of the congestion window and peer receive window is.

Alternatively, an quick stap script to examine these values could also
be useful.

-vlad

> 
>>> http://www.spinics.net/lists/linux-sctp/msg03308.html
>>>
>>>
>>> On Wed, Apr 16, 2014 at 2:57 PM, Matija Glavinic Pecotic
>>> <matija.glavinic-pecotic.ext@nsn.com> wrote:
>>>>
>>>> Hello Vlad,
>>>>
>>>> On 04/14/2014 09:57 PM, ext Vlad Yasevich wrote:
>>>>> The base approach is sound.  The idea is to calculate rwnd based
>>>>> on receiver buffer available.  The algorithm chosen however, is
>>>>> gives a much higher preference to small data and penalizes large
>>>>> data transfers.  We need to figure our something else here..
>>>>
>>>> I don't follow you here. Could you please explain what do you see as
>>>> penalty?
>>>>
>>>> Thanks,
>>>>
>>>> Matija
>>>> -- 
>>>> To unsubscribe from this list: send the line "unsubscribe
>>>> linux-sctp" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>>
>>
