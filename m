From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH net-next v2] bonding: fix strlen errors in sysfs
Date: Fri, 22 Jul 2011 16:51:54 -0400
Message-ID: <20110722205153.GP21309@gospo.rdu.redhat.com>
References: <1310608665-12216-1-git-send-email-andy@greyhouse.net> <201107141115.35452.vitas@nppfactor.kiev.ua> <9576.1310659326@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vitalii Demianets <vitas@nppfactor.kiev.ua>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	Takuma Umeya <tumeya@redhat.com>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61157 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932084Ab1GVUwF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jul 2011 16:52:05 -0400
Content-Disposition: inline
In-Reply-To: <9576.1310659326@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 14, 2011 at 09:02:06AM -0700, Jay Vosburgh wrote:
> Vitalii Demianets <vitas@nppfactor.kiev.ua> wrote:
> 
> >On Thursday 14 July 2011 04:57:45 Andy Gospodarek wrote:
> >> -			if (strnicmp
> >> -			    (slave->dev->name, buf,
> >> -			     strlen(slave->dev->name)) == 0) {
> >> +			int max_len = max(strlen(slave->dev->name),
> >> +					  strlen(buf) - 1);
> >> +			if (strnicmp(slave->dev->name, buf, max_len) == 0) {
> >
> >As for me there is no sense in preventing "address out of range" errors in  
> >strnicmp by calculating length with strlen first. If there is missing \0 at 
> >the end of the string you just shift failure point from stricmp to the strlen 
> >function call.
> >IMHO "maximum length" argument in strnicmp should be some appropriate constant 
> >instead. Alternatively we can use count:
> 
> 	I agree about using a constant, and I nominate IFNAMSIZ for that
> constant.
> 

A constant like IFNAMSIZ can work, but only if buf has the '\n' removed
from the string that is added by echo or other command first.

> 	Also, should we really be using strnicmp?  I.e., case
> insensitive?  Aren't interface names case sensitive?

Probably not.

I'll roll a patch next week that drops the newline and uses IFNAMSIZ if
that is the preference.  I didn't think it was worth the trouble
initially, so I didn't do it that way the first time.

