From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH 1/4] isdn/capi: move capi_info2str to capidrv.c
Date: Sat, 24 May 2014 13:43:31 +0200
Message-ID: <1400931811.22523.25.camel@x220>
References: <cover.1400449368.git.tilman@imap.cc>
		 <365e4f40e1aace19c3233305085ed929b30387b8.1400449370.git.tilman@imap.cc>
		 <537D99F6.4040500@linux-pingi.de> <1400794689.16407.57.camel@x220>
	 <53807C01.9070706@linux-pingi.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tilman Schmidt <tilman@imap.cc>, netdev@vger.kernel.org,
	isdn4linux@listserv.isdn4linux.de,
	"Keil, Karsten" <isdn@linux-pingi.de>
To: Karsten Keil <kkeil@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cpsmtpb-ews06.kpnxchange.com ([213.75.39.9]:54772 "EHLO
	cpsmtpb-ews06.kpnxchange.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750792AbaEXLnd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 May 2014 07:43:33 -0400
In-Reply-To: <53807C01.9070706@linux-pingi.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Karsten,

On Sat, 2014-05-24 at 13:01 +0200, Karsten Keil wrote:
> Am 22.05.2014 23:38, schrieb Paul Bolle:
> > On Thu, 2014-05-22 at 08:32 +0200, Karsten Keil wrote:
> >> I disagree here, since this is a general helper function and should be
> >> not in a special driver, but stay in capiutils.c which is the place for
> >> the driver independent stuff. I used this function from time to time to
> >> instrument other places for debugging as well.
> > 
> > Thanks for commenting. It would be nice if you could also comment on
> > patch 4/4. You might be able to tell whether the things I say there
> > about, well, the history of CAPI (middleware) device nodes are correct,
> > as you were already maintainer during that period, weren't you? 
> 
> Yes I fully agree here, I have the same opinion as Tilman already
> stated. And thanks a lot for this work.

Good to hear, thanks!

> > This patch, 1/4, and patch 2/4, simplify the Kconfig file and the code a
> > bit. It makes it  bit easier to understand how the CAPI code fits
> > together. Same thing with my commit d1958f8c2f0d ("isdn/capi: Make
> > Middleware depend on CAPI2.0"). It is also nice to drop the
> > ISDN_DRV_AVMB1_VERBOSE_REASON name, which only makes sense to people
> > that know the ancient history of this code.
> 
> I'm not against dropping ISDN_DRV_AVMB1_VERBOSE_REASON completely, it
> was introduced in a time in which some KByte of memory did count a lot,
> since the PCs had often less than 4 MByte.

(I wasn't actually proposing to drop it. The patches rename it and move
it, and the code it enables, around a bit.)

> Back to capi_info2str():
> My issue is that this change moves a part of the CAPI20 specification
> out of the capi modules. Everything from the CAPI specification (which
> is also defines these strings), is implemented in the 2 capi modules.

capi_info2str() is currently - speaking from memory - mostly a list of
magic constant and some strings. I know that (most of?) the magic
constants can be mapped to defines elsewhere in the tree. I seem to
remember that these constants came from the spec. I don't care about
capidrv myself, so I resisted the urge to clean it all up.

But, anyhow, do you mean to say that these errors strings themselves are
to be found in a spec?

> The capidrv is not part of the CAPI20 specification, it is only the
> interface between CAPI20 and the old isdn4linux code, you can completely
> run CAPI20 applications without capidrv. If you disable I4L, nobody
> could use the CAPI reason translation. Yes, only the i4l interface
> driver did use it up to now, but this doesn't mean that it is the
> correct place. I think that this do not make it clearer how the code
> fits together.
>
> > Anyhow, this patch might complicate your local debugging practices. That
> > might be inconvenient for you. But in mainline we see a function that's
> > used in one place only. And I think cleaning up mainline code is what
> > counts.
> 
> I'm not against cleaning up.
> If you still think, that we should move the code I do not compain again,
> but I want make sure that you understand why it was in that place and
> that it makes sense from the design of the CAPI20.

So it seems you're saying we could move capi_info2str() into capidrv as
long as we store the magic constants (but, in my opinion, as proper
defines) and the error strings in some central place. Say one of the
capi headers. Is that what you're saying?

That would be quite a bit of tedious work, but it might be worth it.
I'll have to look into that, which might take a few days. Tilman, any
thoughts already?


Paul Bolle
