From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net : Remove unnecessary assignments
Date: Tue, 18 Mar 2014 10:03:26 -0700
Message-ID: <1395162206.2812.56.camel@joe-AO722>
References: <53287010.8000703@gmail.com>
	 <063D6719AE5E284EB5DD2968C1650D6D0F6E0472@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: 'Balakumaran Kannan' <kumaran.4353@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0153.hostedemail.com ([216.40.44.153]:34626 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752135AbaCRRDk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 13:03:40 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6E0472@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-03-18 at 16:22 +0000, David Laight wrote:
> From: Behalf Of Balakumaran Kannan
> > Remove unnecessary assignments
> > 
> > Signed-off-by: Balakumaran Kannan <kumaran.4353@gmail.com>
> > ---
> > Some unnecessary assignments has been removed from devinet_ioctl function.
> > The 'ret' variable is set in multiple places, but used only based on if
> > conditions. So keeping the assignment inside if will be a better.
> ...
> 
> These all seem to be this transform:
> > -	ret = -ENODEV;
> >  	dev = __dev_get_by_name(net, ifr.ifr_name);
> > -	if (!dev)
> > +	if (!dev) {
> > +		ret = -ENODEV;
> >  		goto done;
> > +	}
> 
> I bet that if you look at the generated code you'll find
> that the compiler generates the same code for both forms
> and is likely to generate the equivalent of:
> 	dev = __dev_get_by_name(net, ifr.ifr_name);
> 	ret = -ENODEV;
> 	if (!dev)
> 		goto done;
> 
> So this is just a matter of style.

Yabut it's Linus' preferred style.
http://lkml.org/lkml/2008/12/16/383

(but not mine, I prefer what's done by the patch)
