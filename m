From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2] e1000e: Assign true and false to bool type variable
 instead of 1 and 0
Date: Tue, 06 Dec 2011 23:39:23 -0800
Message-ID: <1323243563.1762.42.camel@joe2Laptop>
References: <4EDED071.40900@linux.vnet.ibm.com>
	 <1323229439.2415.23.camel@jtkirshe-mobl>
	 <1323231268.1762.19.camel@joe2Laptop> <4EDEF05F.4020901@linux.vnet.ibm.com>
	 <1323237700.1762.24.camel@joe2Laptop> <4EDF02CC.4010407@linux.vnet.ibm.com>
	 <1323238749.1762.27.camel@joe2Laptop> <4EDF0964.3080509@linux.vnet.ibm.com>
	 <20111207072050.GC2203@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Michael Wang <wangyun@linux.vnet.ibm.com>,
	jeffrey.t.kirsher@intel.com,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"wangyunlinux@gmail.com" <wangyunlinux@gmail.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:51255 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752703Ab1LGHjY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Dec 2011 02:39:24 -0500
In-Reply-To: <20111207072050.GC2203@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-12-07 at 07:20 +0000, Al Viro wrote:
> On Wed, Dec 07, 2011 at 02:36:20PM +0800, Michael Wang wrote:
> > On 12/07/2011 02:19 PM, Joe Perches wrote:
> 
> [snip]
> > >  	if (*i2cctl & IXGBE_I2C_DATA_IN)
> > > -		data = 1;
> > > +		data = true;
> > >  	else
> > > -		data = 0;
> > > +		data = false;
> > > 
> > >  	return data;
> 
> Yuck...
> 
> bool f(whatever)
> {
> 	bool data;
> 	if (expression)
> 		data = true;
> 	else
> 		data = false;
> 	return data;
> }
> 
> is amazingly unidiomatic.  Hell, if nothing else it's
> 	bool data = expression;
> 	return data;
> if not an outright
> 	return expression;
> or
> 	return (bool)expression;
> if you want to underline that it's treated as boolean...  What tool
> has produced that patch?

tool has multiple meanings... :)

In this case though it's spatch (coccinelle)

I looked at it and thought the same thing as you.

The point though was not to do the idiomatic
transform that you correctly describe, but to
get Michael Wang to look at spatch as a tool
to do those transforms.

cheers, Joe
