From: Andy Johnson <johnsonzjo@gmail.com>
Subject: Re: NETDEV_FEAT_CHANGE and ethtool (question)
Date: Sun, 12 May 2013 23:49:42 +0300
Message-ID: <CAF0Lin2V3QyKCDfZkY_zB8StK+GUR+Qwtb64LQ3maJgVJBT7fw@mail.gmail.com>
References: <CAF0Lin3mWT_GybiXE1AihZj8iRfmQ7ahNg51SHn6BKtbitFm4A@mail.gmail.com>
	<CAHXqBFKwFtM03jg_UqbpHqg2fod_R2gYBHPqJ9YQMmE=ZF68Hw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:59232 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752488Ab3ELUtn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 May 2013 16:49:43 -0400
Received: by mail-wg0-f43.google.com with SMTP id c11so5793886wgh.22
        for <netdev@vger.kernel.org>; Sun, 12 May 2013 13:49:42 -0700 (PDT)
In-Reply-To: <CAHXqBFKwFtM03jg_UqbpHqg2fod_R2gYBHPqJ9YQMmE=ZF68Hw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
Thanks!

You are right.

sorry for missing this:
int dev_ethtool()
{
=2E..
if (old_features !=3D dev->features)
netdev_features_change(dev);
}

Best,
Andy

On Sun, May 12, 2013 at 10:18 PM, Micha=C5=82 Miros=C5=82aw <mirqus@gma=
il.com> wrote:
> 2013/5/12 Andy Johnson <johnsonzjo@gmail.com>:
>> Hello,
>>
>> The only thing that netdev_features_change() does is send
>> NETDEV_FEAT_CHANGE event
>> notification.
>>
>> NETDEV_FEAT_CHANGE event is sent in the core from
>> netdev_update_features() if __netdev_update_features returned 1, and
>> this event is *always* sent from netdev_change_features().
>>
>> ethtool calls __netdev_update_features() when chaning features. So
>> changing GSO offload features for example, by
>> "ethtool -K gso off" will *not* trigger NETDEV_FEAT_CHANGE event not=
ification.
>> (assuming that ndo_fix_features/ndo_set_features callbacks of the
>> driver, if exist, will not
>> trigger such noticiation call).
>>
>> My question is: why changing features by ethtool does not trigger
>> sending NETDEV_FEAT_CHANGE event?
>
> You didn't verify this assumption. See dev_ethtool()'s last check.
>
> Best Regards,
> Micha=C5=82 Miros=C5=82aw
