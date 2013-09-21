From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: Potential out-of-bounds access in ip6_finish_output2
Date: Sat, 21 Sep 2013 11:08:06 -0700
Message-ID: <CACT4Y+ZpToDfkgyqL8Xcab+4noPFwWSUuHd1z1KDB9KqO8fF5Q@mail.gmail.com>
References: <CACT4Y+ZXqoixvCyN5703+sVhCV4ND-vNwash2Z1vSDoLgKNyVg@mail.gmail.com>
 <20130917224851.GB8947@order.stressinduktion.org> <20130921151457.GA5748@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Dmitry Vyukov <dvyukov@google.com>, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org, Paul Turner <pjt@google.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:42134 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751243Ab3IUSI2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Sep 2013 14:08:28 -0400
Received: by mail-la0-f49.google.com with SMTP id ev20so1329521lab.36
        for <netdev@vger.kernel.org>; Sat, 21 Sep 2013 11:08:26 -0700 (PDT)
In-Reply-To: <20130921151457.GA5748@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 21, 2013 at 8:14 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On Wed, Sep 18, 2013 at 12:48:51AM +0200, Hannes Frederic Sowa wrote:
>> On Mon, Sep 16, 2013 at 10:13:10PM -0700, Dmitry Vyukov wrote:
>> > I am working on AddressSanitizer -- a tool that detects use-after-free
>> > and out-of-bounds bugs
>> > (https://code.google.com/p/address-sanitizer/wiki/AddressSanitizerForKernel).
>> >
>> > I've got a dozen of reports in ip6_finish_output2. Below are 2 of
>> > them. They are always followed by kernel crash. Unfortunately I don't
>> > have a reproducer because I am using trinity fuzzer. I would
>> > appreciate if somebody familiar with the code look at sources and
>> > maybe spot the bug.
>>
>> Thanks for the report!
>>
>> I tried reproducing the bug and hit some other bugs nearby. I'll try to fix
>> them, but this could take some time.
>
> I fixed the first bug I encountered with trinity here:
> http://patchwork.ozlabs.org/patch/276835/
>
> The main cause of this bug has nothing to do with raw sockets, so I first
> thought they are not related. But I left my machine run trinity while
> I was sleeping and did not see any other splats (I added some manually
> range checks in ip6_append_data). So maybe your bug happend because the
> premature exit in the dontfrag check without resetting cork->length. Maybe
> you could give this patch a try? I'll have a second look later today.


Hi Hannes!

Testing now with your patch.
I've seen this report very few times, so it will be difficult to say
if it's not happening any more or just not triggered.
