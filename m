From: Joe Perches <joe@perches.com>
Subject: Re: [Linux-zigbee-devel] [PATCH net-next v3] 6lowpan: mac802154:
 fix coding style issues
Date: Tue, 01 Jul 2014 21:58:10 -0700
Message-ID: <1404277090.14624.62.camel@joe-AO725>
References: <1404271869-2316-1-git-send-email-varkab@cdac.in>
	 <CAGVrzcYc9u2TAxhb8vPOevLYiZUsOyEcUAbxZ4aLrns3Vt97yw@mail.gmail.com>
	 <1404276016.14624.57.camel@joe-AO725>
	 <CAGVrzcb6pYdyvuXOrKssjx2fzJqRV=CsdocVNGSSKkEAuUkeYg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Varka Bhadram <varkabhadram@gmail.com>,
	netdev <netdev@vger.kernel.org>, Varka Bhadram <varkab@cdac.in>,
	David Miller <davem@davemloft.net>,
	linux-zigbee-devel@lists.sourceforge.net
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0010.hostedemail.com ([216.40.44.10]:39643 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751186AbaGBE6T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 00:58:19 -0400
In-Reply-To: <CAGVrzcb6pYdyvuXOrKssjx2fzJqRV=CsdocVNGSSKkEAuUkeYg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-07-01 at 21:49 -0700, Florian Fainelli wrote:
> 2014-07-01 21:40 GMT-07:00 Joe Perches <joe@perches.com>:
> > On Tue, 2014-07-01 at 21:20 -0700, Florian Fainelli wrote:
> >> Hi,
> >>
> >> 2014-07-01 20:31 GMT-07:00 Varka Bhadram <varkabhadram@gmail.com>:
> >> > This patch fixed the coding style issues reported by checkpatch.pl
> >> >
> >> > following issues fixed:
> >> >         CHECK: Alignment should match open parenthesis
> >>
> >> It seems to me like checkpatch.pl should have a special case for
> >> networking code and that specific condition because fixing things to
> >> make checkpatch.pl happy seems not to agree with the general coding
> >> style recommended and enforced in the networking code.
> >
> > In networking (net/ and drivers/net) alignment of multiline statements
> > _should_ align to the open parenthesis and checkpatch already has a
> > specific check for those directories.
> >
> >> I just saw that new warning added popping up on a bunch of drivers
> >> that were properly fixed to match the networking coding style before
> >> submission.
> >
> > Is there anything you want changed in checkpatch?
> > If so, why?
> 
> It looks to me like it does some improper flagging when the multi-line
> statements are aligned to the closest tab after the opening
> parenthesis, e.g:
> 
> CHECK: Alignment should match open parenthesis
> #84: FILE: drivers/net/ethernet/broadcom/bcmsysport.c:84:
> +       __raw_writel(upper_32_bits(addr) & DESC_ADDR_HI_MASK,
> +                       d + DESC_ADDR_HI_STATUS_LEN);
> 
> gmail will probably render this incorrectly and does replace tabs with
> spaces, but if you run the script manually on that specific file, it
> will return some (false?) positives matches.
> 
> this is with checkpath.pl from net-next/master at
> 763e0ecd72fe90fdd73bb1aa1b72caf8381d2fff ("bonding: allow to add vlans
> on top of empty bond")

No, it's not a false positive.

The code is currently:

	__raw_writel(upper_32_bits(addr) & DESC_ADDR_HI_MASK,
			d + DESC_ADDR_HI_STATUS_LEN);

1st line has 1 leading tab,
2nd line has 3 leading tabs

For networking code style, this should be:

	__raw_writel(upper_32_bits(addr) & DESC_ADDR_HI_MASK,
		     d + DESC_ADDR_HI_STATUS_LEN);

1st line has 1 leading tab,
2nd line has 2 leading tabs followed by 5 leading spaces

This aligns the 2nd line arguments to the position immediately
after the open parenthesis.
