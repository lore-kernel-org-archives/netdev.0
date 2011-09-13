From: Paul Stewart <pstew@chromium.org>
Subject: Re: [PATCHv2] ipv6: Create module parameter for use_tempaddr
Date: Tue, 13 Sep 2011 12:56:28 -0700
Message-ID: <CAMcMvshXgKCpwLFPzUWvmacTuqmSEjDfPgvZU2BHeC+WcXRH0A@mail.gmail.com>
References: <4E6E62D1.8010108@hp.com>
	<20110912212011.7C65B2041D@glenhelen.mtv.corp.google.com>
	<87r53ks2w3.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:15290 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932421Ab1IMT4c convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2011 15:56:32 -0400
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id p8DJuUbq022781
	for <netdev@vger.kernel.org>; Tue, 13 Sep 2011 12:56:31 -0700
Received: from gyg13 (gyg13.prod.google.com [10.243.50.141])
	by wpaz33.hot.corp.google.com with ESMTP id p8DJswk2025067
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 13 Sep 2011 12:56:29 -0700
Received: by gyg13 with SMTP id 13so1130484gyg.22
        for <netdev@vger.kernel.org>; Tue, 13 Sep 2011 12:56:29 -0700 (PDT)
In-Reply-To: <87r53ks2w3.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 13, 2011 at 11:39 AM, Bj=F8rn Mork <bjorn@mork.no> wrote:
> Paul Stewart <pstew@chromium.org> writes:
>
>> When ipv6 is used as a module, there is no good place to set
>> the default value for use_tempaddr. =A0Using sysctl.conf will
>> set this parameter too early -- before the module is loaded.
>> To solve this, create a module parameter that will set the
>> default value of use_tempaddr for all devices.
>
> How is use_tempaddr any different from the other /proc/sys/net/ipv6/*
> variables? =A0Do you want to add a module parameter for all of them?

With use_tempaddr and ipv6 loaded as a module, there is a gap of time
between addrconf starting up and whatever configuration one would use
to set use_tempaddr (you can't use sysctl.conf since module-load time
might be much later).  By the time boot scripts (or whatever you'd
use) are able to tweak use_tempaddr, it might be too late and the
global-trackable address (related to the MAC address) might end up in
use.  This negates the entire point of use_tempaddr.  If any of the
other flags suffer this badly at module-load time, I'd be happy to add
module parameters for them, but this is the only one that I've come to
be aware of.

> Why can't you run sysctl with an ipv6-specific sysctl.conf at a time
> fitting your boot sequence? =A0Or load the ipv6 module before sysctl =
is
> loads the default sysctl.conf if that is what you want? =A0Or just se=
t the
> variables in your network configuration scripts, prior to bringing th=
e
> interfaces up?
>
> Or do as most people do nowadays: =A0Forget that ipv6 can be built as=
 a
> module, and just use it builtin. =A0It's not like it can be unloaded
> anyway, so building it as a module does not give you anything.

All helpful suggestions.  However, I'm not yet willing to accept the
claim that ipv6 cannot be used as a module unless the rest of the
system is painstakingly crafted to close any races between addrconf,
sysctl and other IPv6-using processes.  That strikes me as far too
brittle.

--
Paul
