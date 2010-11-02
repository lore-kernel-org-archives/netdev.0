From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [Security] [SECURITY] CAN info leak/minor heap overflow
Date: Tue, 2 Nov 2010 15:57:53 -0400
Message-ID: <AANLkTi=EcAQ0u_wYAnVkvV_Ve9in4z2Es5h1pBbyMeXe@mail.gmail.com>
References: <1288722503.2504.14.camel@dan> <4CD069D4.7010801@hartkopp.net> <1288727605.2504.21.camel@dan>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Hartkopp <socketcan@hartkopp.net>, netdev@vger.kernel.org,
	security@kernel.org
To: Dan Rosenberg <drosenberg@vsecurity.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:44550 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750895Ab0KBT66 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Nov 2010 15:58:58 -0400
Received: from mail-yw0-f46.google.com (mail-yw0-f46.google.com [209.85.213.46])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id oA2JwKQQ006426
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=FAIL)
	for <netdev@vger.kernel.org>; Tue, 2 Nov 2010 12:58:28 -0700
Received: by ywc21 with SMTP id 21so2004509ywc.19
        for <netdev@vger.kernel.org>; Tue, 02 Nov 2010 12:58:14 -0700 (PDT)
In-Reply-To: <1288727605.2504.21.camel@dan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 2, 2010 at 3:53 PM, Dan Rosenberg <drosenberg@vsecurity.com=
> wrote:
>
>> Why is this bad? Can the addresses of CAN-BCM sock structs be used f=
or
>> anything from userspace?
>>
>> For me they are just intented to be unique numbers ...
>>
>
> This is a bad idea because it makes exploiting other kernel
> vulnerabilities easier. =A0Exposing the address of an object in a sla=
b
> cache, especially an object that unprivileged users have some level o=
f
> control of, is just an invitation to use that structure when writing
> exploits, for heap overflows or otherwise.

Indeed. At the very least, hash them and truncate them with some
secret per-boot value or something. Even better, use something like a
socket number so that maybe they can be associated with
/proc/<xyz>/fd/<x> or other system info if somebody were to care.

             Linus
