From: Mathieu Poirier <mathieu.poirier@linaro.org>
Subject: Re: [PATCH] net: allow shifted address in smsc911x
Date: Tue, 29 Mar 2011 15:17:22 -0600
Message-ID: <AANLkTinkqvXsyrWdSN9KP+6iZnchvnn8=UECwOcKz6tP@mail.gmail.com>
References: <1301088437-31915-1-git-send-email-mathieu.poirier@linaro.org>
	<20110325.143103.25112180.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: steve.glendinning@smsc.com, netdev@vger.kernel.org,
	lee.jones@linaro.org, patches@linaro.org, linus.walleij@linaro.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:63869 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752809Ab1C2VSL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2011 17:18:11 -0400
Received: by fxm17 with SMTP id 17so573994fxm.19
        for <netdev@vger.kernel.org>; Tue, 29 Mar 2011 14:18:10 -0700 (PDT)
In-Reply-To: <20110325.143103.25112180.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My first email bounced on the list, hence sending again.

Please see my comments below.

Thanks,
Mathieu.

On 25 March 2011 15:31, David Miller <davem@davemloft.net> wrote:
> From: mathieu.poirier@linaro.org
> Date: Fri, 25 Mar 2011 15:27:17 -0600
>
>> From: Alessandro Rubini <rubini@gnudd.com>
>>
>> At least one device I'm using needs address shifting to access
>> registers in the LAN9221 device (smsc911x driver). =A0This patch
>> adds a shift parameter in platform_data. The feature must be
>> enabled at configuration time, because shifting by a pdata
>> parameter makes access slower in those devices where no shift is
>> needed (I tested one, it was 20% slower).
>>
>> If the platform data requests shifted access but the feature is
>> unavailable, the probe method complains to the console. Board
>> config files should set the configuration option when needed.
>>
>> Signed-off-by: Alessandro Rubini <rubini@gnudd.com>
>> Signed-off-by: Mathieu Poirier <mathieu.poirier@linaro.org>
>
> Implement this at run time, keying off of a boolean or similar
> in the platform data.
>
> Implement a set of ops, one to do a PIO read one to do a PIO write,
> and choose the set of ops appropriate for the device depending upon
> the setting found in the platform device.
>

I'm find with this approach but confused on the way to implement it.

I could add the shifted read/write functions in smsc911x.c and choose,
based on a boolean found in the 'smsc911x_platform_config' struct,
which will be used (the original or the shifted methods). =A0The
drawback with this approach is the new shifted read/write methods are
polluting smsc911x.c, something I'm not so fond of. =A0It might be
acceptable for one set of OPS but what if there is many more ?

A better approach would be to pass the read/write methods to the
smsc911x core using the 'smsc911x_platform_config' structure. =A0That
way smsc911x.c is kept clean but we'd have to move 'struct
smsc911x_data' to smsc911x.h to implement the methods from the board
files, something I'm not about do to without some sort of consensus.

'smsc911x_tx_writefifo' and 'smsc911x_rx_readfifo' are also of concern
to me. =A0I understand the usage of writesl/readsl but it introduces
more challenges. =A0If we don't want to replace their usage by a while
loop as it is the case when SMSC911X_SWAP_FIFO and SMSC911X_USE_16BIT
are set, we will need to introduce rx_readfifo and rx_writefifo in the
OPS.

Enlightenment is required on the above.

Best regards,
Mathieu.
