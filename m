From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: Linux 4.12+ memory leak on router with i40e NICs
Date: Mon, 16 Oct 2017 16:56:06 -0700
Message-ID: <CAKgT0Uf=0yasidUfyadNSxzkhKvtxH2t83fjb-SU7OaAnrMReA@mail.gmail.com>
References: <1507121766.30720.4.camel@cohaesio.com> <CAKgT0UfAqzuEbFA_hs8f4goL2hTMqeJ5no2sAc8NO_KJO120tA@mail.gmail.com>
 <1507180753.20182.8.camel@cohaesio.com> <227d17ae-b040-07d0-3c57-e9acd1a3b5b4@itcare.pl>
 <c49a750f-c47c-9de0-ebf0-148db5e3d3c5@itcare.pl> <CAKgT0UcOWxnrsGEjTopPP-JKyKGTG3j6KNKUbhQRgaCStyzr_A@mail.gmail.com>
 <b4995fc8-1420-fe96-26f7-ad5d986b7d39@gmail.com> <3d783736-a474-d9e3-2de2-e35c765f8249@itcare.pl>
 <39696136-2a4a-9c6c-3a63-4485ed2a1bf3@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Pavlos Parissis <pavlos.parissis@gmail.com>,
        "Anders K. Pedersen | Cohaesio" <akp@cohaesio.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "alexander.h.duyck@intel.com" <alexander.h.duyck@intel.com>
To: =?UTF-8?Q?Pawe=C5=82_Staszewski?= <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:51071 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752889AbdJPX4H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 19:56:07 -0400
Received: by mail-qk0-f194.google.com with SMTP id o187so15003237qke.7
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 16:56:07 -0700 (PDT)
In-Reply-To: <39696136-2a4a-9c6c-3a63-4485ed2a1bf3@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 16, 2017 at 4:34 PM, Pawe=C5=82 Staszewski <pstaszewski@itcare.=
pl> wrote:
>
>
> W dniu 2017-10-16 o 18:26, Pawe=C5=82 Staszewski pisze:
>
>>
>>
>> W dniu 2017-10-16 o 13:20, Pavlos Parissis pisze:
>>>
>>> On 15/10/2017 02:58 =CF=80=CE=BC, Alexander Duyck wrote:
>>>>
>>>> Hi Pawel,
>>>>
>>>> To clarify is that Dave Miller's tree or Linus's that you are talking
>>>> about? If it is Dave's tree how long ago was it you pulled it since I
>>>> think the fix was just pushed by Jeff Kirsher a few days ago.
>>>>
>>>> The issue should be fixed in the following commit:
>>>>
>>>> https://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git/commit/d=
rivers/net/ethernet/intel/i40e/i40e_txrx.c?id=3D2b9478ffc550f17c6cd8c690572=
34e91150f5972
>>>>
>>>
>>> Do you know when it is going to be available on net-next and linux-stab=
le
>>> repos?
>>>
>>> Cheers,
>>> Pavlos
>>>
>>>
>> I will make some tests today night with "net" git tree where this patch =
is
>> included.
>> Starting from 0:00 CET
>> :)
>>
>>
> Upgraded and looks like problem is not solved with that patch
> Currently running system with
> https://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git/
> kernel
>
> Still about 0.5GB of memory is leaking somewhere
>
> Also can confirm that the latest kernel where memory is not leaking (with
> use i40e driver intel 710 cards) is 4.11.12
> With kernel 4.11.12 - after hour no change in memory usage.
>
> also checked that with ixgbe instead of i40e with same  net.git kernel th=
ere
> is no memleak - after hour same memory usage - so for 100% this is i40e
> driver problem.

So how long was the run to get the .5GB of memory leaking?

Also is there any chance of you being able to bisect to determine
where the memory leak was introduced since as you pointed out it
didn't exist in 4.11.12 so odds are it was introduced somewhere
between 4.11 and the latest kernel release.

Thanks.

- Alex
