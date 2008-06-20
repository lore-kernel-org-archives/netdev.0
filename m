From: Eric Miao <eric.y.miao@gmail.com>
Subject: Re: [PATCH 5/8] smc91x: add SMC91X_IO_SHIFT* macros and make SMC_IO_SHIFT
 a variable
Date: Fri, 20 Jun 2008 17:19:23 +0800
Message-ID: <485B761B.9010706@gmail.com>
References: <485A3E0B.1080505@gmail.com> <alpine.LFD.1.10.0806191223390.2982@xanadu.home> <485B2850.5050004@gmail.com> <20080620072939.GA1479@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: Eric Miao <eric.y.miao@gmail.com>, Nicolas Pitre <nico@cam.org>,
	linux-netdev <netdev@vger.kernel.org>,
	Magnus Damm <magnus.damm@gmail.com>,
	linux-arm-kernel <linux-arm-kernel@lists.a
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.234]:58602 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751548AbYFTJTg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2008 05:19:36 -0400
Received: by rv-out-0506.google.com with SMTP id k40so5581959rvb.1
        for <netdev@vger.kernel.org>; Fri, 20 Jun 2008 02:19:35 -0700 (PDT)
In-Reply-To: <20080620072939.GA1479@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sascha Hauer wrote:
> Your numbers look like a very bad overall performance. I remember we got
> nearly 100Mbit/s on a pxa system with the smsc connected in 32bit mode.
> While this project was performance critical I'm often in the situation
> that I just expect the smsc driver to work without looking at the
> ifdeffery in the header file.
> Shouldn't it be possible to make access macros optional for those who
> want performance and use functions as the default case?
> 

This isn't a serious performance test. I just want to give myself a
rough feeling of the degrade level in a casual way.

Using a centralized function will be the ultimate solution to handle
difference between platforms, that requires another bunch of patches.
And there are also some exceptions like mainstone, which uses its own
SMC_outw() to workaround something buggy in hardware.

To have this driver supporting so many platforms at run-time is really
a head-scratching work, and may eventually introduce some trade-offs :-/

> 
>> So I'm thinking that the overhead may not be so significant as expected,
>> 1. control register accesses are rare compared to data register
>> 2. data register access is usually fixed at one address and enclosed in
>>    a loop, which the compiler may well optimize
>>
>>> And this is very important to have the lowest overhead possible with 
>>> this chip that can do 100mbps on platforms with a CPU clock almost as 
>>> slow.
>>>
>> Indeed, the overhead will be magnified on a system with slow CPU clock,
>> maybe I should spend some time to have a test also. However, arguably,
>> the smc91x chips are usually used as a debug ethernet on most (if not
>> all) platforms, I don't think a serious design will deploy such a chip
>> for performance critical application, though.
> 
> Not anymore probably, but we seem to tun into the same problem with the
> current smc911x driver aswell

Indeed.

> 
> Sascha
> 
> 

