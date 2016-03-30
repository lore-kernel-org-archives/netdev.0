From: Ezequiel Garcia <ezequiel@vanguardiasur.com.ar>
Subject: Re: [PATCH] ethernet: mvneta: Support netpoll
Date: Wed, 30 Mar 2016 01:59:13 -0300
Message-ID: <CAAEAJfCYH5SnhiPyJCeBTquj8roUnt3AxQ2rWwugo=tN+EUZTA@mail.gmail.com>
References: <1459197678-12022-1-git-send-email-ezequiel@vanguardiasur.com.ar>
	<20160329.230930.1234182429605936870.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:34834 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751635AbcC3E7O convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 00:59:14 -0400
Received: by mail-wm0-f53.google.com with SMTP id 191so74477019wmq.0
        for <netdev@vger.kernel.org>; Tue, 29 Mar 2016 21:59:14 -0700 (PDT)
In-Reply-To: <20160329.230930.1234182429605936870.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On 30 March 2016 at 00:09, David Miller <davem@davemloft.net> wrote:
> From: Ezequiel Garcia <ezequiel@vanguardiasur.com.ar>
> Date: Mon, 28 Mar 2016 17:41:18 -0300
>
>> +/* Polled functionality used by netconsole and others in non interr=
upt mode */
>> +static void mvneta_poll_controller(struct net_device *dev)
>> +{
>> +     struct mvneta_port *pp =3D netdev_priv(dev);
>> +
>> +     on_each_cpu(mvneta_percpu_poll_controller, pp, false);
>> +}
>
> This doesn't work.
>
> netpoll may be invoked from any context whatsoever, even hardware
> interrupt handlers or contexts where cpu interrupts are disabled.
>
> smp_call_function() and thus on_each_cpu() may not be called with
> disabled interrupts or from a hardware interrupt handler or from
> a bottom half handler, all of which are valid situations where
> netpoll may occur since printk's can occur anywhere.

Well, I hated the idea of using on_each_cpu here, but wasn't sure
if there was a real reason that forbid it.

Thanks a lot for the feedback.
--=20
Ezequiel Garc=C3=ADa, VanguardiaSur
www.vanguardiasur.com.ar
