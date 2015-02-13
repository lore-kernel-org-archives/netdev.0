From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: Re: [PATCH] iwl4965: Enable checking of format strings
Date: Fri, 13 Feb 2015 13:04:47 +0100
Message-ID: <87twyqxbj4.fsf@rasmusvillemoes.dk>
References: <1423695069-23436-1-git-send-email-linux@rasmusvillemoes.dk>
	<60178C37-F104-430E-92EB-B6DDFAEB2F99@intel.com>
	<87vbj7zb0e.fsf@rasmusvillemoes.dk> <54DDAE03.4000502@gmail.com>
	<87y4o2xfgz.fsf@rasmusvillemoes.dk>
	<063D6719AE5E284EB5DD2968C1650D6D1CAE3325@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Mark Rustad <mrustad@gmail.com>,
	"Rustad\, Mark D" <mark.d.rustad@intel.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	"linux-wireless\@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:49476 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752753AbbBMMEv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2015 07:04:51 -0500
Received: by mail-lb0-f176.google.com with SMTP id u10so15095820lbd.7
        for <netdev@vger.kernel.org>; Fri, 13 Feb 2015 04:04:50 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CAE3325@AcuExch.aculab.com>
	(David Laight's message of "Fri, 13 Feb 2015 11:20:47 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 13 2015, David Laight <David.Laight@ACULAB.COM> wrote:

> From: Rasmus Villemoes
>> Well, probably the linker is allowed to overlap "anonymous" objects
>> (string literals) with whatever const char[] (or indeed any const)
>> object it finds containing the appropriate byte sequence. But I think
>> language lawyers would insist that for
>> 
>> const char foo[] = "a string";
>> const char bar[] = "a string";
>
> A quick test shows those are separate strings.
> But 'const char *foo = "xxx";' will share.

Yes, of course, because in that case you are actually creating two
objects, "xxx" which the linker will find some place to put, and foo
which is initialized to the address of whereever "xxx" was/will be
put. So one is wasting sizeof(const char*). Also, passing foo to a
function means the compiler has to load the value of foo and use that,
instead of simply passing the compile-time (well, link-time) constant
address of "xxx".

> You also need -O1 to get the strings into .rodata.str.n so that the linker
> can merge them.

Sure, optimization has to be turned on, but isn't the kernel always
compiled with -O2? ISTR that there are some things which won't even
work/compile with -O0.

Rasmus
