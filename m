From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: Linux 4.12+ memory leak on router with i40e NICs
Date: Thu, 19 Oct 2017 08:40:54 -0700
Message-ID: <CAKgT0Ud1ftJ187qz_XBVnx+X_1BQTgWWe4sA307_3VmpMSSVaw@mail.gmail.com>
References: <1507121766.30720.4.camel@cohaesio.com> <c49a750f-c47c-9de0-ebf0-148db5e3d3c5@itcare.pl>
 <CAKgT0UcOWxnrsGEjTopPP-JKyKGTG3j6KNKUbhQRgaCStyzr_A@mail.gmail.com>
 <b4995fc8-1420-fe96-26f7-ad5d986b7d39@gmail.com> <3d783736-a474-d9e3-2de2-e35c765f8249@itcare.pl>
 <39696136-2a4a-9c6c-3a63-4485ed2a1bf3@itcare.pl> <CAKgT0Uf=0yasidUfyadNSxzkhKvtxH2t83fjb-SU7OaAnrMReA@mail.gmail.com>
 <310ce203-0d65-bdf4-d9e4-897a349b3277@itcare.pl> <f6e2208a-4cdf-3303-5999-92186b437b62@itcare.pl>
 <1704eb26-c4c5-b196-ca7a-5265e92ae4e6@itcare.pl> <bd82f85a-f9b8-a09a-beab-67667b58f36a@itcare.pl>
 <7fd828d7-c586-2c32-3ba6-e0575bf9958c@itcare.pl> <99eba19f-327e-e01f-4f4a-87540b176e40@itcare.pl>
 <efcc51b4-f911-11ec-1c56-fcf31081f9d5@itcare.pl> <d79df7f2-5de4-cc37-baf0-5603f025155e@itcare.pl>
 <748b6d9d-4a3f-4eaa-ad24-27060c2e2642@itcare.pl> <16c9fa34-252f-e5a3-8b15-e5a8c4d8a46f@itcare.pl>
 <12670bc6-439c-7ef4-109a-fd20384b9ca2@itcare.pl> <bd59ccc3-2af4-6842-8d2f-169229a61470@itcare.pl>
 <888ec430-1d70-68e6-2ee8-bab53d21bb0f@itcare.pl> <CAKgT0Ud=GRrsNtoM0gOgzsh1uPJ7nuT9S-xbigmbUMi+iz-ufw@mail.gmail.com>
 <1508415582.1186.49.camel@cohaesio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "pstaszewski@itcare.pl" <pstaszewski@itcare.pl>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "pavlos.parissis@gmail.com" <pavlos.parissis@gmail.com>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "alexander.h.duyck@intel.com" <alexander.h.duyck@intel.com>
To: "Anders K. Pedersen | Cohaesio" <akp@cohaesio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f171.google.com ([209.85.216.171]:56150 "EHLO
        mail-qt0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752668AbdJSPk4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 11:40:56 -0400
Received: by mail-qt0-f171.google.com with SMTP id v41so14911383qtv.12
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 08:40:56 -0700 (PDT)
In-Reply-To: <1508415582.1186.49.camel@cohaesio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 19, 2017 at 5:19 AM, Anders K. Pedersen | Cohaesio
<akp@cohaesio.com> wrote:
> Hi Alex,
>
> On ons, 2017-10-18 at 16:37 -0700, Alexander Duyck wrote:
>> When we last talked I had asked if you could do a git bisect to find
>> the memory leak and you said you would look into it. The most useful
>> way to solve this would be to do a git bisect between your current
>> kernel and the 4.11 kernel to find the point at which this started.
>> If
>> we can do that then fixing this becomes much simpler as we just have
>> to fix the patch that introduced the issue.
>
> We're also seeing a smaller memory leak (about 1 GB per day) than the
> original one even with the "Fix memory leak related filter programming
> status" fix applied. So far I've determined that the leak is present on
> 4.13.7 and was introduced between 4.11 and 4.12, so I'll do another
> round of bisection to identify the patch that introduced this.
>
> Since the router must run for a couple of hours before I can be sure
> whether a kernel is good or bad, and I can't reboot it during working
> hours, it'll probably be about a week before I have a result.
>
> --
> Venlig hilsen / Best Regards
>
> Anders K. Pedersen
> Senior Technical Manager

Anders,

I'll do some digging on my side to see if I can find any other memory
leaks that might be floating around in the driver that could have been
introduced during that time-frame.

One thing you might try that would help with your testing would be to
just disable the ATR functionality in i40e. You can do that with the
ethtool command "ethtool --set-priv-flags <iface> flow-director-atr
off". That should allow you to bisect this without needing to deal
with the "programming status" patches since you won't be programming
ATR filters which is what caused that leak.

Thanks for looking into this.

- Alex
