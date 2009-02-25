From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPv4/IPv6 sysctl unregistration deadlock
Date: Wed, 25 Feb 2009 16:43:21 +0800
Message-ID: <20090225084321.GA1101@gondor.apana.org.au>
References: <49A4D5D5.5090602@trash.net> <20090225061902.GA32430@gondor.apana.org.au> <49A4E3F8.4050406@trash.net> <49A4F0D7.20304@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:33822 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755674AbZBYIn0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2009 03:43:26 -0500
Content-Disposition: inline
In-Reply-To: <49A4F0D7.20304@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 25, 2009 at 08:18:47AM +0100, Patrick McHardy wrote:
>
> Unfortunately its more complicated than I thought because of
> device renames, where the sysctl pointer is reused after
> unregistration and the rename/unregistration/re-registration
> should be atomic. Deferring unregistration means we can't perform
> the new registration immediately unless we allow multiple
> registrations for a single device to be active simulaneously,
> which introduces a whole new set of problems.

Good point.

> Simply ignoring the request during unregistration doesn't seem
> so bad after all, the main problem is that it intoduces a different
> race on renames where a write to the "forwarding" file returns
> success, but the change doesn't take effect. We could return
> -ENOENT, but that seems a bit strange after open() returned success.
> Maybe -EBUSY, although I would prefer to make this transparent
> to userspace.

I'd like to avoid that for the rename case just because shell
scripts know how to deal with echo foo > /nonexist/file but not
necessarily a failed echo on write/close.

> I think I'm stuck. Will rethink it after some coffee :)

Yes we need more coffee :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
