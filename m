From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2 3/3] ss: Filtering logic changing, with fixes
Date: Sun, 4 Jan 2015 00:58:11 +0200
Message-ID: <20150103225811.GA5972@angus-think.lan>
References: <1420245877-11763-1-git-send-email-vadim4j@gmail.com>
 <1420245877-11763-4-git-send-email-vadim4j@gmail.com>
 <20150103095707.37e69147@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f47.google.com ([209.85.215.47]:44054 "EHLO
	mail-la0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752049AbbACXI3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Jan 2015 18:08:29 -0500
Received: by mail-la0-f47.google.com with SMTP id hz20so16320337lab.6
        for <netdev@vger.kernel.org>; Sat, 03 Jan 2015 15:08:28 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20150103095707.37e69147@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 03, 2015 at 09:57:07AM -0800, Stephen Hemminger wrote:
> On Sat,  3 Jan 2015 02:44:37 +0200
> Vadim Kochan <vadim4j@gmail.com> wrote:
> 
> > +struct filter default_dbs[MAX_DB] = {
> > +	[TCP_DB] = {
> > +		.states   = SS_CONN,
> > +		.families = (1 << AF_INET) | (1 << AF_INET6),
> > +	},
> 
> I like table driven code, so this is good. But please make
> mark the table as const.

I did re-test, and I still don't like very much my results (some cases
are not logically) even if they (IMHO) better than the 'master' version,
so I will try to change filer options applying in the following way:

    0) default filter should have only default states & all dbs

    1) apply all selected families with their default dbs & states from table

    2) logical AND selected dbs with dbs of the selected families and their default
        states from table, also select families by db from table if there no
        already selected families

    3) logical AND selected states with selected dbs and their default states from table,
        also select families and dbs from table by states if there no
        already selected dbs & families

So with such approach the options should affect each other in the strict
predictable way:

    families -> dbs (socket tables) -> socket states

I hope I will success with this ...

I appreciate any feedback.

Regards,
Vadim Kochan
