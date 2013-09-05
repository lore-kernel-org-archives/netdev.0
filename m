From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH] openvswitch: Fix alignment of struct sw_flow_key.
Date: Thu, 5 Sep 2013 11:36:19 -0700
Message-ID: <CAEP_g=8gcCtkv=no=HkVmS+NDWPM-Uu-SVyR+vb-YQ=7TWJsXA@mail.gmail.com>
References: <1378402887-17331-1-git-send-email-jesse@nicira.com> <20130905.141751.945639989861997124.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	Andy Zhou <azhou@nicira.com>, fengguan.wu@intel.com,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog104.obsmtp.com ([74.125.149.73]:41523 "HELO
	na3sys009aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752458Ab3IESgl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Sep 2013 14:36:41 -0400
Received: by mail-lb0-f173.google.com with SMTP id o14so2000927lbi.4
        for <netdev@vger.kernel.org>; Thu, 05 Sep 2013 11:36:40 -0700 (PDT)
In-Reply-To: <20130905.141751.945639989861997124.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 5, 2013 at 11:17 AM, David Miller <davem@davemloft.net> wrote:
> From: Jesse Gross <jesse@nicira.com>
> Date: Thu,  5 Sep 2013 10:41:27 -0700
>
>> -} __aligned(__alignof__(long));
>> +} __aligned(8); /* 8 byte alignment ensures this can be accessed as a long */
>
> This kind of stuff drives me crazy.
>
> If the issue is the type, therefore at least use an expression that
> mentions the type explicitly.  And mention the actual type that
> matters.  "long" isn't it.

'long' actually is the real type here.

When doing comparisons, this structure is being accessed as a byte
array in 'long' sized chunks, not by its members. Therefore, the
compiler's alignment does not necessarily correspond to anything for
this purpose. It could be a struct full of u16's and we would still
want to access it in chunks of 'long'.

To completely honest, I think the correct alignment should be
sizeof(long) because I know that 'long' is not always 8 bytes on all
architectures. However, you made the point before that this could
break the alignment of the 64-bit values on architectures where 'long'
is 32 bits wide, so 8 bytes is the generic solution.
