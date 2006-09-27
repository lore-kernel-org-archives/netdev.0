From: David Miller <davem@davemloft.net>
Subject: Re: [PKT_SCHED] cls_basic: Use unsigned int when generating handle
Date: Wed, 27 Sep 2006 16:18:48 -0700 (PDT)
Message-ID: <20060927.161848.122030745.davem@davemloft.net>
References: <20060927100939.GZ18349@postel.suug.ch>
	<Pine.LNX.4.44.0609271441390.9010-100000@dhcp09282.ntc.nokia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, kaber@trash.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:12738
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1031227AbWI0XSt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Sep 2006 19:18:49 -0400
To: Kim.Nordlund@nokia.com
In-Reply-To: <Pine.LNX.4.44.0609271441390.9010-100000@dhcp09282.ntc.nokia.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Nordlund Kim (Nokia-NET/Helsinki)" <Kim.Nordlund@nokia.com>
Date: Wed, 27 Sep 2006 14:45:21 +0300 (EEST)

> But for signed types it falls under this:
> 
>     6.5 Expressions
>     5 If an exceptional condition occurs during the evaluation of an
>     expression (that is, if the
>     result is not mathematically defined or not in the range of
>     representable values for its
>     type), the behavior is undefined.
> 
> Already the initial assignment of 0x80000000 to int falls under this:
> 
>     6.3.1.3 Signed and unsigned integers
>     1 When a value with integer type is converted to another integer type
>     other than _Bool, if
>     the value can be represented by the new type, it is unchanged.
>     2 Otherwise, if the new type is unsigned, the value is converted by
>     repeatedly adding or
>     subtracting one more than the maximum value that can be represented
>     in the new type
>     until the value is in the range of the new type.49)
>     3 Otherwise, the new type is signed and the value cannot be
>     represented in it; either the
>     result is implementation-defined or an implementation-defined signal
>     is raised.
> 
> Of course it can be argued whether the gcc optimization is sane. But it
> seems not to be wrong, and there is no justification for writing the code
> to be unspecified.

Correct, and actually this undefined behavior turns out to be
critical for several types of loop optimizations which I feel
totally justifies the interpretation gcc is using now.

I'll apply Thomas's original patch, thanks.
