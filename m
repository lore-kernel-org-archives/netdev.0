From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH net-next] macvlan: fix failure during registration v3
Date: Tue, 26 Apr 2016 14:36:37 -0700
Message-ID: <CAF2d9jjVP+VGBosOdHSNvCc8YGzr76d202GVeUUH_f9C0nW8PQ@mail.gmail.com>
References: <1461449012-7401-1-git-send-email-fruggeri@arista.com>
 <CAF2d9jh98MGYorJ=btvx04==EsjP5_ivUEimf0TJ1NUPDzG4nw@mail.gmail.com> <CA+HUmGgYf8BkaPqYxvuDtuUY5JC90QC-6_mxEQ6DWRcaoeid2Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-netdev <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"David S. Miller" <davem@davemloft.net>
To: Francesco Ruggeri <fruggeri@arista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f177.google.com ([209.85.161.177]:33545 "EHLO
	mail-yw0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752201AbcDZVg6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 17:36:58 -0400
Received: by mail-yw0-f177.google.com with SMTP id t10so40281197ywa.0
        for <netdev@vger.kernel.org>; Tue, 26 Apr 2016 14:36:57 -0700 (PDT)
In-Reply-To: <CA+HUmGgYf8BkaPqYxvuDtuUY5JC90QC-6_mxEQ6DWRcaoeid2Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[...]
>> > -destroy_port:
>> > -       port->count -= 1;
>> > -       if (!port->count)
>> > -               macvlan_port_destroy(lowerdev);
>> I think you still need this when it fails netdev_upper_dev_link(). The
>> only thing you should remove is the label.
>
> I don't think so. I think the double decrement also occurred in this case.
> unregister_netdevice invokes rollback_registered/macvlan_uninit
> which does the decrement.
>
I thought macvlan_port_destroy() does not get called but it is called
from macvlan_uninit(). So it's all good. Thanks.

> Thanks,
> Francesco
>
>> >
>> >         return err;
>> >  }
>> > --
>> > 1.8.1.4
>> >
