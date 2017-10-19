From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: Linux 4.12+ memory leak on router with i40e NICs
Date: Thu, 19 Oct 2017 08:53:24 -0700
Message-ID: <CAKgT0UeHBXw+d-y=4_Ady-T8Uiv0e7igWzWrMQHj_OrYr=XzgQ@mail.gmail.com>
References: <1507121766.30720.4.camel@cohaesio.com> <CAKgT0UfAqzuEbFA_hs8f4goL2hTMqeJ5no2sAc8NO_KJO120tA@mail.gmail.com>
 <1507180753.20182.8.camel@cohaesio.com> <227d17ae-b040-07d0-3c57-e9acd1a3b5b4@itcare.pl>
 <c49a750f-c47c-9de0-ebf0-148db5e3d3c5@itcare.pl> <CAKgT0UcOWxnrsGEjTopPP-JKyKGTG3j6KNKUbhQRgaCStyzr_A@mail.gmail.com>
 <b4995fc8-1420-fe96-26f7-ad5d986b7d39@gmail.com> <3d783736-a474-d9e3-2de2-e35c765f8249@itcare.pl>
 <39696136-2a4a-9c6c-3a63-4485ed2a1bf3@itcare.pl> <20171017055155.GA19944@pc11.op.pod.cz>
 <CAKgT0Udb5DVu6CB5U7rGNERZwMCKZUTii=qxn6hFzc=5zEZc1w@mail.gmail.com>
 <57579746-77e1-4603-12ed-7d999fdfeabf@itcare.pl> <CABOTfnOtw=XdhPL4n1JM16CS02ekoy6EPugOvtSbO6LGp2XOXA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: =?UTF-8?Q?Pawe=C5=82_Staszewski?= <pstaszewski@itcare.pl>,
        "Anders K. Pedersen | Cohaesio" <akp@cohaesio.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "alexander.h.duyck@intel.com" <alexander.h.duyck@intel.com>
To: Pavlos Parissis <pavlos.parissis@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f178.google.com ([209.85.220.178]:43997 "EHLO
        mail-qk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752047AbdJSPxZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 11:53:25 -0400
Received: by mail-qk0-f178.google.com with SMTP id w134so10933229qkb.0
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 08:53:25 -0700 (PDT)
In-Reply-To: <CABOTfnOtw=XdhPL4n1JM16CS02ekoy6EPugOvtSbO6LGp2XOXA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 19, 2017 at 4:41 AM, Pavlos Parissis
<pavlos.parissis@gmail.com> wrote:
> On 19 October 2017 at 01:40, Pawe=C5=82 Staszewski <pstaszewski@itcare.pl=
> wrote:
>>
>>
>> W dniu 2017-10-19 o 01:29, Alexander Duyck pisze:
>>
>>> On Mon, Oct 16, 2017 at 10:51 PM, Vitezslav Samel <vitezslav@samel.cz>
>>> wrote:
>>>>
>>>> On Tue, Oct 17, 2017 at 01:34:29AM +0200, Pawe=C5=82 Staszewski wrote:
>>>>>
>>>>> W dniu 2017-10-16 o 18:26, Pawe=C5=82 Staszewski pisze:
>>>>>>
>>>>>> W dniu 2017-10-16 o 13:20, Pavlos Parissis pisze:
>>>>>>>
>>>>>>> On 15/10/2017 02:58 =CF=80=CE=BC, Alexander Duyck wrote:
>>>>>>>>
>>>>>>>> Hi Pawel,
>>>>>>>>
>>>>>>>> To clarify is that Dave Miller's tree or Linus's that you are talk=
ing
>>>>>>>> about? If it is Dave's tree how long ago was it you pulled it sinc=
e I
>>>>>>>> think the fix was just pushed by Jeff Kirsher a few days ago.
>>>>>>>>
>>>>>>>> The issue should be fixed in the following commit:
>>>>>>>>
>>>>>>>> https://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git/comm=
it/drivers/net/ethernet/intel/i40e/i40e_txrx.c?id=3D2b9478ffc550f17c6cd8c69=
057234e91150f5972
>>>>>>>
>>>>>>> Do you know when it is going to be available on net-next and
>>>>>>> linux-stable repos?
>>>>>>>
>>>>>>> Cheers,
>>>>>>> Pavlos
>>>>>>>
>>>>>>>
>>>>>> I will make some tests today night with "net" git tree where this pa=
tch
>>>>>> is included.
>>>>>> Starting from 0:00 CET
>>>>>> :)
>>>>>>
>>>>>>
>>>>> Upgraded and looks like problem is not solved with that patch
>>>>> Currently running system with
>>>>> https://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git/
>>>>> kernel
>>>>>
>>>>> Still about 0.5GB of memory is leaking somewhere
>>>>>
>>>>> Also can confirm that the latest kernel where memory is not leaking
>>>>> (with
>>>>> use i40e driver intel 710 cards) is 4.11.12
>>>>> With kernel 4.11.12 - after hour no change in memory usage.
>>>>>
>>>>> also checked that with ixgbe instead of i40e with same  net.git kerne=
l
>>>>> there
>>>>> is no memleak - after hour same memory usage - so for 100% this is i4=
0e
>>>>> driver problem.
>>>>
>>>>    I have (probably) the same problem here but with X520 cards: bootin=
g
>>>> 4.12.x gives me oops after circa 20 minutes of our workload. Booting
>>>> 4.9.y is OK. This machine is in production so any testing is very
>>>> limited.
>>>>
>>>>    Machine was stable for >2 months (on the desk before got to
>>>> production) with 4.12.8 but with no traffic on X520 cards.
>>>>
>>>>          Cheers,
>>>>
>>>>                  Vita
>>>
>>> Sorry but it can't be the same issue since we are discussing a
>>> different driver (i40e) running different hardware (X710 or XL170).
>>> You might want to start a new thread for your issue, and/or if
>>> possible file a bug on e1000.sf.net.
>>>
>>> Thanks.
>>>
>>> - Alex
>>>
>> sorry but bugs reported on e1000.sf.net are delayed - some after about 6=
 or
>> more months - when i reported first bug there iv got reply after a year
>> about no activity :):) haha - and reported there bug is still actrive :)
>> better for me is now to change nics (for sure cheaper from  the perspect=
ive
>> of clients :) ) to mellanox or just to replace and use ixgbe - that have=
 no
>> this bug (mellanox and ixgbe have no such bug - have many servers with t=
hem
>> with same conf - and only one with i40e where is same conf and memleak)
>>
>> If nobody from Intel wants to reproduce this - qool - this is not my pro=
blem
>> but intels :) - there is now many good nics to use - like mellanox or ju=
st
>> stick with many 10G based on ixgbe that is really good driver - but real=
ly ?
>> intel guys have no XL710 cards ? i dont want to buy another buggy cards =
to
>> do only kernel bisects .... sorry ....
>> To do good bisects with this bug You need to spend maybee 200/300 bisect=
s -
>> and to confirm each - You need maybee 30minutes so count how much time Y=
ou
>> need - more that 100 cards in price from mellanox maybee :)
>>
>
> I have similar issues with you in regards to the stability of i40e
> driver. I will need to open another thread about them, but I would
> like to mention that you are not the only one who suffers from
> problems related to i40e driver. In my case I can't simply change
> NICs..so it is even worse.
>
> Cheers,
> Pavlos

Hi Pavlos,

If you want feel free to Cc either my gmail or my intel.com email
address when you start the new thread, and I can work with you to try
to resolve the issues you are experiencing.

I'm just wanting to split up the unrelated issues into separate
threads as it is easier to track them as single threads. It makes it
much easier to figure out when an actual issue such as the original
memory leak was resolved versus trying to work multiple issues on the
same thread which makes things confusing as you end up losing track of
what the issue being resolved actually is, and it makes it confusing
for people who are reviewing the mailing list for issues similar to
what they are experiencing.

Thanks for your input, and I look forward to working with you to
resolve the issue you are experiencing.

- Alex
