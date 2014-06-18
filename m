From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH net-next 5/5] net: sctp: fix incorrect type in gfp
 initializer
Date: Wed, 18 Jun 2014 14:30:58 -0400
Message-ID: <20140618183058.GC11042@htj.dyndns.org>
References: <1402497297-27100-1-git-send-email-dborkman@redhat.com>
 <1402497297-27100-6-git-send-email-dborkman@redhat.com>
 <063D6719AE5E284EB5DD2968C1650D6D1725AF78@AcuExch.aculab.com>
 <5398712C.3000801@redhat.com>
 <CAADnVQLyNCUU0+onEHbygVE-M3WK59uB=NoKWi1V4Rh+6AZkVA@mail.gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D1725B905@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 'Alexei Starovoitov' <alexei.starovoitov@gmail.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f51.google.com ([209.85.216.51]:65430 "EHLO
	mail-qa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754040AbaFRSbC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2014 14:31:02 -0400
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1725B905@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 12, 2014 at 08:46:44AM +0000, David Laight wrote:
> I was slightly worried it might generate the boolean value - something
> that you really don't want it to do.

I don't think gcc is that stupid at this point.

> I only looked at the output for the old version.
> The compiler seemed to have converted:
> 	if (preload)
> 		x();
> 	y;
> 	if (preload)
> 		z();
> into:
> 	if (preload) {
> 		x(); y; z();
> 	} else {
> 		y;
> 	}
> and then found out that z() was empty, leaving two copies of y().

So, nothing wrong, right?

-- 
tejun
