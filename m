From: "Nordlund Kim (Nokia-NET/Helsinki)" <Kim.Nordlund@nokia.com>
Subject: Re: [PKT_SCHED] cls_basic: Use unsigned int when generating handle
Date: Wed, 27 Sep 2006 14:45:21 +0300 (EEST)
Message-ID: <Pine.LNX.4.44.0609271441390.9010-100000@dhcp09282.ntc.nokia.com>
References: <20060927100939.GZ18349@postel.suug.ch>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>,
	"Nordlund Kim (Nokia-NET/Helsinki)" <Kim.Nordlund@nokia.com>,
	<davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw-ext14.nokia.com ([131.228.20.173]:2669 "EHLO
	mgw-ext14.nokia.com") by vger.kernel.org with ESMTP
	id S1751100AbWI0Lsk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Sep 2006 07:48:40 -0400
To: ext Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060927100939.GZ18349@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Wed, 27 Sep 2006, ext Thomas Graf wrote:

> gcc >= 4.1 seems to produce this code with either -Os or -O2
> so the range of affected useres might in fact be bigger.

I believe gcc >= 4.1 is just updating to match ISO/IEC 9899:1999: 
This piece of code crosses undefined behaviour as defined in

    3.4.3
    1 undefined behavior
    behavior, upon use of a nonportable or erroneous program construct or
    of erroneous data,
    for which this International Standard imposes no requirements
    2 NOTE Possible undefined behavior ranges from ignoring the situation
    completely with unpredictable
    results, to behaving during translation or program execution in a
    documented manner characteristic of the
    environment (with or without the issuance of a diagnostic message),
    to terminating a translation or
    execution (with the issuance of a diagnostic message).
    3 EXAMPLE An example of undefined behavior is the behavior on integer
    overflow.

For undefined types there is no overflow:

    6.2.5 Types

    9 The range of nonnegative values of a signed integer type is a
    subrange of the
    corresponding unsigned integer type, and the representation of the
    same value in each
    type is the same.31) A computation involving unsigned operands can
    never overflow,
    because a result that cannot be represented by the resulting unsigned
    integer type is
    reduced modulo the number that is one greater than the largest value
    that can be
    represented by the resulting type.

But for signed types it falls under this:

    6.5 Expressions
    5 If an exceptional condition occurs during the evaluation of an
    expression (that is, if the
    result is not mathematically defined or not in the range of
    representable values for its
    type), the behavior is undefined.

Already the initial assignment of 0x80000000 to int falls under this:

    6.3.1.3 Signed and unsigned integers
    1 When a value with integer type is converted to another integer type
    other than _Bool, if
    the value can be represented by the new type, it is unchanged.
    2 Otherwise, if the new type is unsigned, the value is converted by
    repeatedly adding or
    subtracting one more than the maximum value that can be represented
    in the new type
    until the value is in the range of the new type.49)
    3 Otherwise, the new type is signed and the value cannot be
    represented in it; either the
    result is implementation-defined or an implementation-defined signal
    is raised.

Of course it can be argued whether the gcc optimization is sane. But it
seems not to be wrong, and there is no justification for writing the code
to be unspecified.

--KimN



