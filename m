From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next 3/5] fou: fix byte order of udp_config.local_udp_port
Date: Tue, 7 Apr 2015 14:11:24 -0700
Message-ID: <CAM_iQpX0ZzVH-OOo=bP7Mm9_0BzJ+aVwK30CiUok24hrTcYzAA@mail.gmail.com>
References: <1428363690-16288-1-git-send-email-xiyou.wangcong@gmail.com>
	<1428363690-16288-4-git-send-email-xiyou.wangcong@gmail.com>
	<CALx6S350kJnG=Qv9MGBK9O9AciCU-y6s+moxm2oxCJ86SC1Eeg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:32832 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753300AbbDGVLZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 17:11:25 -0400
Received: by pdbnk13 with SMTP id nk13so91431456pdb.0
        for <netdev@vger.kernel.org>; Tue, 07 Apr 2015 14:11:24 -0700 (PDT)
In-Reply-To: <CALx6S350kJnG=Qv9MGBK9O9AciCU-y6s+moxm2oxCJ86SC1Eeg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 6, 2015 at 11:09 PM, Tom Herbert <tom@herbertland.com> wrote:
> On Mon, Apr 6, 2015 at 4:41 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
>> index ad0ee82..cf606fc 100644
>> --- a/net/ipv4/fou.c
>> +++ b/net/ipv4/fou.c
>> @@ -468,7 +468,7 @@ static int fou_create(struct net *net, struct fou_cfg *cfg,
>>         sk = sock->sk;
>>
>>         fou->flags = cfg->flags;
>> -       fou->port = cfg->udp_config.local_udp_port;
>> +       fou->port = ntohs(cfg->udp_config.local_udp_port);
>>
> Cong, I don't think this is right. Port should always be nbo, probably
> should be using __b16 instead of u16 for defines. Did you test these
> changes?
>

Yeah, fou->port is u16 which should be host order, however
we only save and compare it with be16, so the original code
is not mis-behaving (otherwise should go to -net), just reads odd.

I tested it together with the whole patchset. And I agree we can
change fou->port to be16 too.

I will wait for more feedback before sending v2.

Thanks!
