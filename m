From: Karsten Keil <kkeil@linux-pingi.de>
Subject: Re: [PATCH 1/4] isdn/capi: move capi_info2str to capidrv.c
Date: Sat, 24 May 2014 13:01:21 +0200
Message-ID: <53807C01.9070706@linux-pingi.de>
References: <cover.1400449368.git.tilman@imap.cc>	 <365e4f40e1aace19c3233305085ed929b30387b8.1400449370.git.tilman@imap.cc>	 <537D99F6.4040500@linux-pingi.de> <1400794689.16407.57.camel@x220>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Tilman Schmidt <tilman@imap.cc>, netdev@vger.kernel.org,
	isdn4linux@listserv.isdn4linux.de,
	"Keil, Karsten" <isdn@linux-pingi.de>
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.131]:64682 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751154AbaEXLB3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 May 2014 07:01:29 -0400
In-Reply-To: <1400794689.16407.57.camel@x220>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Paul,

Am 22.05.2014 23:38, schrieb Paul Bolle:
> Karsten,
> 
> On Thu, 2014-05-22 at 08:32 +0200, Karsten Keil wrote:
>> Am 21.05.2014 23:39, schrieb Tilman Schmidt: 
>>> capi_info2str() is apparently meant to be of general utility. It is
>>> actually only used in capidrv.c. So move it from capiutil.c to
>>> capidrv.c and (obviously) stop exporting it.
>>>
>>> And, since we're touching this, merge the two versions of this
>>> function.
>>
>> I disagree here, since this is a general helper function and should be
>> not in a special driver, but stay in capiutils.c which is the place for
>> the driver independent stuff. I used this function from time to time to
>> instrument other places for debugging as well.
> 
> Thanks for commenting. It would be nice if you could also comment on
> patch 4/4. You might be able to tell whether the things I say there
> about, well, the history of CAPI (middleware) device nodes are correct,
> as you were already maintainer during that period, weren't you?
> 

Yes I fully agree here, I have the same opinion as Tilman already
stated. And thanks a lot for this work.

> This patch, 1/4, and patch 2/4, simplify the Kconfig file and the code a
> bit. It makes it  bit easier to understand how the CAPI code fits
> together. Same thing with my commit d1958f8c2f0d ("isdn/capi: Make
> Middleware depend on CAPI2.0"). It is also nice to drop the
> ISDN_DRV_AVMB1_VERBOSE_REASON name, which only makes sense to people
> that know the ancient history of this code.

I'm not against dropping ISDN_DRV_AVMB1_VERBOSE_REASON completely, it
was introduced in a time in which some KByte of memory did count a lot,
since the PCs had often less than 4 MByte.

Back to capi_info2str():
My issue is that this change moves a part of the CAPI20 specification
out of the capi modules. Everything from the CAPI specification (which
is also defines these strings), is implemented in the 2 capi modules.
The capidrv is not part of the CAPI20 specification, it is only the
interface between CAPI20 and the old isdn4linux code, you can completely
run CAPI20 applications without capidrv. If you disable I4L, nobody
could use the CAPI reason translation. Yes, only the i4l interface
driver did use it up to now, but this doesn't mean that it is the
correct place. I think that this do not make it clearer how the code
fits together.

> 
> Anyhow, this patch might complicate your local debugging practices. That
> might be inconvenient for you. But in mainline we see a function that's
> used in one place only. And I think cleaning up mainline code is what
> counts.
> 

I'm not against cleaning up.
If you still think, that we should move the code I do not compain again,
but I want make sure that you understand why it was in that place and
that it makes sense from the design of the CAPI20.

Thanks again for your value work.

Karsten
