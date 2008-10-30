From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: [PATCH 1/4] printk: add %I4, %I6, %i4, %i6 format specifiers
Date: Thu, 30 Oct 2008 16:59:59 -0700
Message-ID: <1225411199.5574.3.camel@brick>
References: <1225305340.5688.36.camel@brick>
	 <1225398538.1288.9.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.174]:42002 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754096AbYJaAAC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 20:00:02 -0400
Received: by wf-out-1314.google.com with SMTP id 24so1014352wfg.15
        for <netdev@vger.kernel.org>; Thu, 30 Oct 2008 17:00:01 -0700 (PDT)
In-Reply-To: <1225398538.1288.9.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-10-30 at 13:28 -0700, Joe Perches wrote:
> On Wed, 2008-10-29 at 11:35 -0700, Harvey Harrison wrote:
> >  		return ip6_addr_string(buf, end, ptr, field_width, precision, flags);
> > +	case 'i':
> > +		flags |= SPECIAL;
> > +		/* Fallthrough */
> > +	case 'I':
> > +		if (fmt[1] == '6')
> > +			return ip6_addr_string(buf, end, ptr, field_width, precision, flags);
> > +		if (fmt[1] == '4')
> > +			return ip4_addr_string(buf, end, ptr, field_width, precision, flags);
> > +		flags &= ~SPECIAL;
> > +		break;
> >  	}
> >  	flags |= SMALL;
> >  	if (field_width == -1) {
> 
> Hi Harvey.
> 
> I was thinking about extending %p<foo> to support
> struct task_struct * and noticed this code isn't
> really correct.
> 
> SPECIAL should be cleared from flags only when *fmt
> is 'i' not 'I' and SPECIAL wasn't previously set.
> 

SPECIAL is set when # is used with the p modifier...which warns as we've
already seen.  So the only way to set special in the %p case is to use
i.  Instead of having an if() I just unconditionally clear it (perhaps
unnecessarily).  Mind you, we only get here if you pass in %p[iI][not 4 or 6]

Cheers,

Harvey

