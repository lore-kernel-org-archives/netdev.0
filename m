From: Cong Wang <cwang@twopensource.com>
Subject: Re: Suspicious RCU usage in bridge with Linux v4.0-9362-g1fc149933fd4
Date: Mon, 4 May 2015 14:38:23 -0700
Message-ID: <CAHA+R7OD7Bh52MkB1hKs8DdncrgBN2_1VYQwrFGetJFJ7chgyg@mail.gmail.com>
References: <CA+5PVA5gE_pG5iPKBgugsEjLsOYvq9bWKfB+2OeEujjdOb+URg@mail.gmail.com>
	<20150504133943.GA17043@x131e>
	<CAHA+R7PAzzz+CZfnOoweBdeLY8tRkr2bSDEpQgdtEKUeaZbWpQ@mail.gmail.com>
	<1430772572.27254.3.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dominick Grift <dac.override@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:33027 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752764AbbEDViY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 17:38:24 -0400
Received: by wgin8 with SMTP id n8so163508793wgi.0
        for <netdev@vger.kernel.org>; Mon, 04 May 2015 14:38:23 -0700 (PDT)
In-Reply-To: <1430772572.27254.3.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 4, 2015 at 1:49 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2015-05-04 at 11:45 -0700, Cong Wang wrote:
>> On Mon, May 4, 2015 at 6:39 AM, Dominick Grift <dac.override@gmail.com> wrote:
>> > On Thu, Apr 23, 2015 at 01:07:45PM -0400, Josh Boyer wrote:
>> >> Hi All,
>> >>
>> >> We've had a user report the following backtrace from the bridge module
>> >> with a recent Linus' tree.  Has anything like this been reported yet?
>> >> If you have any questions on setup, the user is CC'd.
>> >>
>> >> josh
>> >>
>> >> [   29.382235] br0: port 1(tap0) entered forwarding state
>> >>
>> >> [   29.382286] ===============================
>> >> [   29.382315] [ INFO: suspicious RCU usage. ]
>> >> [   29.382344] 4.1.0-0.rc0.git11.1.fc23.x86_64 #1 Not tainted
>> >> [   29.382380] -------------------------------
>> >> [   29.382409] net/bridge/br_private.h:626 suspicious
>> >> rcu_dereference_check() usage!
>> >
>> > <snip>
>> >
>> > With 4.1.0-0.rc1.git1.1.fc23.x86_64 the situation seems to have slightly changed:
>> >
>>
>> Should be the same issue. Please give the attached patch a try,
>> it is compile-tested only.
>>
>> Thanks!
>
> Please send inline patches, otherwise its hard for us to review them and
> give feedback.


Compile-test only patch is never ready for review, I thought it is too obvious
to mention.

>
> At first glance, it is way too complicated.
>
> br_get_vlan_info() change is not needed :
>
> rcu_dereference_rtnl() can already be used from RCU or RTNL protected
> code.
>
> (Quite different from rtnl_dereference())
>
> What about :

Feel free to submit a formal patch, I apparently don't have time to read more
into this, nor have time to argument on details.

Thanks.
