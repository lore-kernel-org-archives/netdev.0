From: Jens Axboe <axboe@fb.com>
Subject: Re: codel: split into multiple files
Date: Tue, 26 Apr 2016 08:37:05 -0600
Message-ID: <571F7D11.6070803@fb.com>
References: <CA+icZUWrRbBJM3q7SzRSc2znAXZHr1JdXHD2j2POKvDin4=CZg@mail.gmail.com>
 <CA+BoTQn2h8XQ5PwTm4Zy2-6JZs-muW2FmA0kVWf9OYCYgQ3T2g@mail.gmail.com>
 <CA+icZUVinohrHUNpKti-QA52eeSztmRTH1sFHpK+YSm98yGrAA@mail.gmail.com>
 <CA+BoTQmovjcYFA4JQBDNQwJHmu=MjZg_HnDn4+KbTi6vYcVV7A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Michal Kazior <michal.kazior@tieto.com>, <sedat.dilek@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:25176 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752511AbcDZOhO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 10:37:14 -0400
In-Reply-To: <CA+BoTQmovjcYFA4JQBDNQwJHmu=MjZg_HnDn4+KbTi6vYcVV7A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/26/2016 06:36 AM, Michal Kazior wrote:
> On 26 April 2016 at 08:43, Sedat Dilek <sedat.dilek@gmail.com> wrote:
>> On 4/26/16, Michal Kazior <michal.kazior@tieto.com> wrote:
>>> On 26 April 2016 at 08:09, Sedat Dilek <sedat.dilek@gmail.com> wrote:
>>>> Hi,
>>>>
>>>> I had a very quick view on net-next.git#master (up to commit
>>>> fab7b629a82da1b59620470d13152aff975239f6).
>>>>
>>>> Commit in [1] aka "codel: split into multiple files" removed codel.h
>>>> but [2] and [3] have relicts to it.
>>>> Forgot to remove?
>>>
>>> codel.h was not removed. diffstat for codel.h is all red which I
>>> presume is why you thought of it as removed, see:
>>>
>>> http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/tree/include/net/codel.h?id=d068ca2ae2e614b9a418fb3b5f1fd4cf996ff032
>>>
>>
>> [ CC Jens ]
>>
>> OK.
>> So what are the plans in the future?
>> Keep a "generic" codel.h (compatibility reasons?) for net or is it your split?
>
> I'm interested in re-using codel in mac80211 for wireless. cfg80211
> drivers may want to do that as well later. Even vendor drivers could
> start to use it (I can dream :).
>
> I plan to re-spin my patches soonish re-based on the new codel.h/fq.h
> approach. There's quite a few spins already[1].
>
>
>> AFAICS I have seen a codel-implementation in block.git#wb-buf-throttle.
>> Does it make sense to have a more "super-generic" codel.h for re-use
>> (not only for net and block)?
>> Just a thought.
>
> Oh, I'm not really familiar with block and problems around it but it
> sounds reasonable and interesting. It doesn't look like it blatantly
> copies codel though (I did that in my initial mac80211 patches with
> some adjustments, you can check that in the link[1] which you can
> lookup via my patchset's cover letter[2]; I've based off of codel5[3]
> back then).

The block version is an adaptation, I guess you can say it pays homage 
to CoDel. But there are a sufficient amount of differences between 
networking and storage that I don't think a fully generic version is 
really feasible. My favorite thing to bring up is the fact that we don't 
have the luxury of dropping packets on the storage side...

-- 
Jens Axboe
