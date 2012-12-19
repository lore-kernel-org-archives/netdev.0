From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH v2] netlink: align attributes on 64-bits
Date: Wed, 19 Dec 2012 17:20:12 +0000
Message-ID: <20121219172012.GC6975@casper.infradead.org>
References: <1355500160.2626.9.camel@bwh-desktop.uk.solarflarecom.com>
 <1355762980-4285-1-git-send-email-nicolas.dichtel@6wind.com>
 <20121218125735.GG27746@casper.infradead.org>
 <50D09897.8030508@6wind.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B70F5@saturn3.aculab.com>
 <20121218171103.GI27746@casper.infradead.org>
 <AE90C24D6B3A694183C094C60CF0A2F6026B70F6@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nicolas.dichtel@6wind.com, bhutchings@solarflare.com,
	netdev@vger.kernel.org, davem@davemloft.net
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:35626 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755776Ab2LSRUQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2012 12:20:16 -0500
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B70F6@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/19/12 at 09:17am, David Laight wrote:
> You can't use memcpy() to copy a pointer to a misaligned
> structure into an aligned buffer. The compiler assumes
> the pointer is aligned and will use instructions that
> depend on the alignment.

I am not sure I understand this correctly. Are you saying
that the following does not work on i386?

struct foo {
  uint32_t a;
  uint64_t b;
};

struct foo buf;

memcpy(&buf, nla_data(attr), nla_len(attr));
printf([...], buf.b);


> I think:
> 1) Alignment is only needed on systems that have 'strict alignment'
>    requirements (maybe disable for testing?)

Right, what about mixed 32bit/64bit environments?

> 2) Alignment is only needed for parameters whose size is a
>    multiple of the alignment (a structure containing a
>    field that needs 8 byte alignment will always be a multiple
>    of 8 bytes long).

Good point. I'll fix this in the next iteration of the patch.

> 3) You need to add NA_HDR_LEN to the write pointer before
>    determining the size of the pad.

Right, I'm doing this in the patch I proposed. Or are you referring
to something else?
