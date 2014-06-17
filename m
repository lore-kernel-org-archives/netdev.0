From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Device Tree Binding for Marvell DSA on P1023RDB
Date: Tue, 17 Jun 2014 09:44:58 -0700
Message-ID: <CAGVrzcY-khbCM3rB5qsNSq2Y+ekeH-4RyW-A-3+Di1MUVhXy4w@mail.gmail.com>
References: <539F1B3F.6060203@xsmail.com> <539F1B8E.30503@xsmail.com>
 <CAGVrzcbxBE0yk5J1Pvkz5Yx+ugHTBjRSTLsvN9NACt20vjmgjw@mail.gmail.com> <539FE2FC.4020105@xsmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Pannirselvam Kanagaratnam <pannir@xsmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f53.google.com ([209.85.219.53]:64340 "EHLO
	mail-oa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965229AbaFQQpj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2014 12:45:39 -0400
Received: by mail-oa0-f53.google.com with SMTP id l6so9036402oag.40
        for <netdev@vger.kernel.org>; Tue, 17 Jun 2014 09:45:38 -0700 (PDT)
In-Reply-To: <539FE2FC.4020105@xsmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Jun 16, 2014 11:41 PM, "Pannirselvam Kanagaratnam" <pannir@xsmail.com> wrote:
>
>
> On 17/06/2014 12:38 AM, Florian Fainelli wrote:
>>
>> 2014-06-16 9:30 GMT-07:00 Pannirselvam Kanagaratnam <pannir@xsmail.com>:
>> Distributed Switch Architecture driver version 0.1
>> dsa: probe of dsa.16 failed with error -22
>> This error might not come from dsa_of_probe(), please instrument the
>> code where -EINVAL is returned to see exactly which part of the
>> probing code is failing.
>
>
> The error is coming from:
>
> dev = dev_to_net_device(pd->netdev);
> if (dev == NULL) {
>                 ret = -EINVAL;
>                 goto out;
>         }

Ok, I could not find which Freescale Ethernet driver you are using,
but my guess is that we cannot look up the struct net_device that is
associated with the struct platform_device of your network driver,
most likely because the network driver failed to call
SET_NETDEV_DEV(). Also, if your Ethernet driver is modular, that might
be a problem if it get probed after DSA.

>
> Is my device tree ok?

It is.
--
Florian
