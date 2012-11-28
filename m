From: Steve Glendinning <steve@shawell.net>
Subject: Re: [PATCH] smsc95xx: fix suspend buffer overflow
Date: Wed, 28 Nov 2012 18:06:05 +0000
Message-ID: <CAKh2mn4pJG-F4zxpBj3MmRSNSV1Gwnxjw=kvfD0xqqYxErdEHg@mail.gmail.com>
References: <1354022623-7317-1-git-send-email-steve.glendinning@shawell.net>
	<1354038178.8028.0.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Steve Glendinning <steve.glendinning@shawell.net>,
	netdev <netdev@vger.kernel.org>,
	Dan Carpenter <dan.carpenter@oracle.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:35243 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754443Ab2K1SGH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 13:06:07 -0500
Received: by mail-ee0-f46.google.com with SMTP id e53so5914631eek.19
        for <netdev@vger.kernel.org>; Wed, 28 Nov 2012 10:06:06 -0800 (PST)
In-Reply-To: <1354038178.8028.0.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>       if (pdata->wolopts & (WAKE_BCAST | WAKE_MCAST | WAKE_ARP | WAKE_UCAST)) {
>> -             u32 *filter_mask = kzalloc(32, GFP_KERNEL);
>> +             u32 *filter_mask = kzalloc(sizeof(u32) * 32, GFP_KERNEL);
>
> It's also unchecked for alloc failure.

Thanks both, I've resubmitted with an alloc failure check,

I completely agree - that filter code isn't pretty!  If you have time
to knock up a patch I'd be happy to test it.

Steve
