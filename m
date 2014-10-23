From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 1/2] net: dsa: Error out on tagging protocol mismatches
Date: Thu, 23 Oct 2014 15:32:03 +0200
Message-ID: <20141023133203.GA25190@lunn.ch>
References: <1414020918-20903-1-git-send-email-andrew@lunn.ch>
 <1414020918-20903-2-git-send-email-andrew@lunn.ch>
 <544841EC.4070103@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Lunn <andrew@lunn.ch>, davem@davemloft.net,
	netdev@vger.kernel.org, alexander.h.duyck@intel.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42558 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750901AbaJWNc6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Oct 2014 09:32:58 -0400
Content-Disposition: inline
In-Reply-To: <544841EC.4070103@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 22, 2014 at 04:46:52PM -0700, Florian Fainelli wrote:
> On 10/22/2014 04:35 PM, Andrew Lunn wrote:
> > If there is a mismatch between enabled tagging protocols and the
> > protocol the switch supports, error out, rather than continue with a
> > situation which is unlikely to work.
> > 
> > Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> > cc: alexander.h.duyck@intel.com
> > ---
> >  net/dsa/dsa.c | 3 ++-
> >  1 file changed, 2 insertions(+), 1 deletion(-)
> > 
> > diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
> > index 22f34cf4cb27..8a31bd81a315 100644
> > --- a/net/dsa/dsa.c
> > +++ b/net/dsa/dsa.c
> > @@ -175,7 +175,8 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
> >  			break;
> >  #endif
> >  		default:
> > -			break;
> > +			ret = -ENOPROTOOPT;
> > +			goto out;
> >  		}
> 
> This prevents using a switch driver without tagging, which is something
> that you might want to do (link setup, ethtool stats, EEE etc...).

Hi Florian

I didn't know that was a use case.

So i assume such a driver would use DSA_TAG_PROTO_NONE? So all i need
to do is add that as a case value to the switch statement, and we
should cover that use case, and still be able to detect a mismatch.

v2 patch soon.

   Andrew
