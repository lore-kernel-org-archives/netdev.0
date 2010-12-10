From: Joe Perches <joe@perches.com>
Subject: RE: [net-next-2.6 25/27] e1000e: static analysis tools complain of
 a possible null ptr p dereference
Date: Fri, 10 Dec 2010 11:58:31 -0800
Message-ID: <1292011111.24978.34.camel@Joe-Laptop>
References: <1291975585-30576-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1291975585-30576-2-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1291985090.24978.17.camel@Joe-Laptop>
	 <EA929A9653AAE14F841771FB1DE5A136602D54FD2F@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"bphilips@novell.com" <bphilips@novell.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"bphilips@novell.com" <bphilips@novell.com>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2500 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755486Ab0LJT6e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Dec 2010 14:58:34 -0500
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A136602D54FD2F@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-12-10 at 12:35 -0700, Tantilov, Emil S wrote:
> >On Fri, 2010-12-10 at 02:06 -0800, Jeff Kirsher wrote:
> >> diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
> >[]
> >> +		default:
> >> +			data[i] = 0;
> >> +			continue;
> >> +			break;
> >Using
> >	continue;
> >	break;
> >is odd and unhelpful.
> >Just continue; is sufficient and clear.
> It's odd and without consequence but not necessarily "unhelpful" as it
> can protect from bugs in case someone was to add another case
> statement.

continue statements are not fall-through.

Adding another case statement in the switch below
this case label would work just fine.

> While unlikely, bugs in switch statements due to missing breaks are
> not unheard of.

True, but that's not this case.

> Looking at the kernel source there is no consistency as far as break
> in the default: case is concerned.

It's not the break, it's the break after continue that's odd.

Glancing through the source code using
	$ grep -rP --include=*.[ch] -B 3 "\bcontinue\s*;\s*break\s*;" *
this is a pretty unusual coding style.

Most all of the matches are like:
	if (condition)
		continue;
	break;

Your choice, your code.  I just think it's ugly
as well as odd and unhelpful.

cheers, Joe

