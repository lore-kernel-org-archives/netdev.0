From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH v2] e1000e: Assign true and false to bool type variable
 instead of 1 and 0
Date: Wed, 7 Dec 2011 07:20:50 +0000
Message-ID: <20111207072050.GC2203@ZenIV.linux.org.uk>
References: <4EDED071.40900@linux.vnet.ibm.com>
 <1323229439.2415.23.camel@jtkirshe-mobl>
 <1323231268.1762.19.camel@joe2Laptop>
 <4EDEF05F.4020901@linux.vnet.ibm.com>
 <1323237700.1762.24.camel@joe2Laptop>
 <4EDF02CC.4010407@linux.vnet.ibm.com>
 <1323238749.1762.27.camel@joe2Laptop>
 <4EDF0964.3080509@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joe Perches <joe@perches.com>, jeffrey.t.kirsher@intel.com,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"wangyunlinux@gmail.com" <wangyunlinux@gmail.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: Michael Wang <wangyun@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:57500 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752270Ab1LGHVB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2011 02:21:01 -0500
Content-Disposition: inline
In-Reply-To: <4EDF0964.3080509@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 07, 2011 at 02:36:20PM +0800, Michael Wang wrote:
> On 12/07/2011 02:19 PM, Joe Perches wrote:

[snip]
> >  	if (*i2cctl & IXGBE_I2C_DATA_IN)
> > -		data = 1;
> > +		data = true;
> >  	else
> > -		data = 0;
> > +		data = false;
> > 
> >  	return data;

Yuck...

bool f(whatever)
{
	bool data;
	if (expression)
		data = true;
	else
		data = false;
	return data;
}

is amazingly unidiomatic.  Hell, if nothing else it's
	bool data = expression;
	return data;
if not an outright
	return expression;
or
	return (bool)expression;
if you want to underline that it's treated as boolean...  What tool
has produced that patch?
