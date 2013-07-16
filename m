From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net 1/6] bnx2x: properly initialize statistic counters
Date: Tue, 16 Jul 2013 11:35:46 -0700
Message-ID: <1373999746.1949.14.camel@joe-AO722>
References: <1373988107-305-1-git-send-email-dmitry@broadcom.com>
	 <1373988107-305-2-git-send-email-dmitry@broadcom.com>
	 <1373991870.1949.3.camel@joe-AO722>
	 <CAM8tLiPqKWxO7w9kL2LjGxFNth6oRV7-JccU+LXiFk9Roass5w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Dmitry Kravkov <dmitry@broadcom.com>,
	Dave Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Dmitry Kravkov <dkravkov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:42091 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933489Ab3GPSfr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jul 2013 14:35:47 -0400
In-Reply-To: <CAM8tLiPqKWxO7w9kL2LjGxFNth6oRV7-JccU+LXiFk9Roass5w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-07-16 at 21:14 +0300, Dmitry Kravkov wrote:
> On Tue, Jul 16, 2013 at 7:24 PM, Joe Perches <joe@perches.com> wrote:
> > It might be better to remove init_fw_counter from
> > stack and use a #define or just use cpu_to_le16(0xffff)
> > in each init.
> 
> I'm not feel well for using same value in each init, probably is better to use
> multiple assignment like this:
>     counters->xstats_counter =
>         counters->tstats_counter =
>         counters->ustats_counter =
>         counters->cstats_counter = cpu_to_le16(0xffff);

Your choice though maybe here's a couple of things
to consider:

I do think aligning all the counter variables useful
when reading so

	count->xstats_counter =
	count->tstats_counter =
	count->ustats_counter =
	count->cstats_counter = foo;

would be better.  Unfortunately grep wouldn't show
that actual initialization where:

	count->xstats_counter = foo;
	count->tstats_counter = foo;
	count->ustats_counter = foo;
	count->cstats_counter = foo;

would and the compiler would do the same thing as
the a = b = c = d = foo; case.
