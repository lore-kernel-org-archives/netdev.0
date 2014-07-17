From: Veaceslav Falico <vfalico@gmail.com>
Subject: Re: [PATCH net-next 1/2] net: use dev->name in netdev_pr* when it's
 available
Date: Thu, 17 Jul 2014 16:30:01 +0200
Message-ID: <20140717143001.GB28357@mikrodark.usersys.redhat.com>
References: <1405596491-5881-1-git-send-email-vfalico@gmail.com>
 <1405596491-5881-2-git-send-email-vfalico@gmail.com>
 <CAG-2HqXhU5RHkMOyj9H2CboYJ1LNFnXzXC_QaAML8P1tihmahg@mail.gmail.com>
 <20140717140158.GA28357@mikrodark.usersys.redhat.com>
 <CAG-2HqXq0fGVE-29p9vuks86U+40EEkOBUioEofQHmZ1Uetbqw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Tom Gundersen <teg@jklm.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f51.google.com ([74.125.82.51]:57360 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932401AbaGQOdC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 10:33:02 -0400
Received: by mail-wg0-f51.google.com with SMTP id b13so2113843wgh.34
        for <netdev@vger.kernel.org>; Thu, 17 Jul 2014 07:33:00 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAG-2HqXq0fGVE-29p9vuks86U+40EEkOBUioEofQHmZ1Uetbqw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 17, 2014 at 04:29:21PM +0200, Tom Gundersen wrote:
>On Thu, Jul 17, 2014 at 4:01 PM, Veaceslav Falico <vfalico@gmail.com> wrote:
>> On Thu, Jul 17, 2014 at 03:48:45PM +0200, Tom Gundersen wrote:
>>>
>>> On Thu, Jul 17, 2014 at 1:28 PM, Veaceslav Falico <vfalico@gmail.com>
>>> wrote:
>>>>
>>>> e() returns dev->name only when the net_device is in
>>>> NETREG_REGISTERED state.
>>>>
>>>> However, dev->name is always populated on creation, so we can easily use
>>>> it. The only caveat is that the device still has a name of type "eth%d",
>>>> in
>>>> which case we cannot use this name as it'll change in the nearest future,
>>>> thus return "unnamed net_device".
>>>
>>>
>>> There are also cases when the name is set to emptystring before being
>>> populated with the real name later on. You may want to check for that
>>> too.
>>
>>
>> Sure, it'd be easy enough.
>>
>> Out of curiosity - can you point me to where it's an empty string?
>
>Only a handfull places (and I didn't check if those actually use the
>print functions before setting the real name):

Yeah, indeed, missed those.

Sent v2.

Thanks a lot!

>
>$ git grep alloc_netdev | grep \"\"
>drivers/net/hamradio/dmascc.c:    info->dev[0] = alloc_netdev(0, "",
>NET_NAME_UNKNOWN, dev_setup);
>drivers/net/hamradio/dmascc.c:    info->dev[1] = alloc_netdev(0, "",
>NET_NAME_UNKNOWN, dev_setup);
>drivers/net/ppp/ppp_generic.c:    dev = alloc_netdev(sizeof(struct
>ppp), "", NET_NAME_UNKNOWN,
>drivers/net/wireless/airo.c:    dev = alloc_netdev(sizeof(*ai), "",
>NET_NAME_UNKNOWN, ether_setup);
>net/atm/clip.c:    dev = alloc_netdev(sizeof(struct clip_priv), "",
>NET_NAME_UNKNOWN,
>
>Cheers,
>
>Tom
