From: Phil Sutter <phil@nwl.cc>
Subject: Re: [net-next PATCH iproute2 v2 1/1] tc: introduce IFE action
Date: Thu, 10 Mar 2016 14:12:40 +0100
Message-ID: <20160310131240.GA19221@orbyte.nwl.cc>
References: <1457525076-6923-1-git-send-email-jhs@emojatatu.com>
 <1457525076-6923-2-git-send-email-jhs@emojatatu.com>
 <20160309131214.GB27306@orbyte.nwl.cc>
 <56E16BB5.4070802@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemming@brocade.com, netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:41671 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750924AbcCJNMn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Mar 2016 08:12:43 -0500
Content-Disposition: inline
In-Reply-To: <56E16BB5.4070802@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 10, 2016 at 07:42:29AM -0500, Jamal Hadi Salim wrote:
> On 16-03-09 08:12 AM, Phil Sutter wrote:
> > On Wed, Mar 09, 2016 at 07:04:36AM -0500, Jamal Hadi Salim wrote:
> >> +static void ife_explain(void)
> >> +{
> >> +	fprintf(stderr,
> >> +		"Usage:... ife {decode|encode} {ALLOW|USE} [dst DMAC] [src SMAC] [type TYPE] [CONTROL] [index INDEX]\n");
> >
> > I'm just nitpicking here, but this syntax implies that ALLOW and USE are
> > mandatory and mutually exclusive. Looking at the code they're neither
> > (although specifying both might not make sense). OTOH you could probably
> > 'use mark' and 'allow prio'. So I'd suggest '[ALLOW] [USE]' instead.
> >
> 
> Maybe we need to come up with some consistent regex/bnf
> scheme. And then lets review all usage code and fix. Here are the rules
> for this case:
> Default: "allow" will be used for all metadata.
> You can specify zero or more "allows", one per metadata
> You can specify zero or more "use", one per metadata.
> 
> This is why my thinking was it was going to read
> [ALLOW|USE] which needed to read as [ALLOW|USE]*

Sure, this is still overly simplified. Using syntactically correct BNF
in help texts though is not worth the effort IMHO, as readability will
suffer tremendously.

> Example, I dont see "{..}" making good sense in any bnf/regex scheme.

They way I interpreted it so far (and is apparently used) is as a way of
having an XOR. E.g. 'bla { foo | bar }' is valid for 'bla foo' and 'bla
bar', but not just 'bla' or 'bla foo bar'.

Assuming that it's possible for allow/use statements to override
previous ones (the code permits that), correct BNF would probably look
like this:

| ife {decode|encode} [AULIST] [dst DMAC] [src SMAC] [type TYPE] [CONTROL] [index INDEX]
|
| AULIST := [AULIST] AU
| AU := {allow|use} {mark|prio}

Of course there are different BNF variants and AFAICT the syntax used in
iproute2 doesn't cleanly stick to any of them. So speaking of 'correct'
is somewhat nonsensical when I define the rules at the same time. :)

> > I'm missing a list of what actual keywords can be given, but after all
> > this is just a help text and a man page will provide much more detail
> > anyway (which you are about to submit too, are you? :).
> >
> 
> Phil, Phil - someday, yes ;->

I'll keep that in mind! But seriously, if we treated man page (updates)
as a substantial part of new features or code changes in general,
quality was higher - not only of documentation, but code as well.

> > Apart from that:
> >
> > Acked-by: Phil Sutter <phil@nwl.cc>
> >
> 
> Lets please get this in and we can then do a general check on all.

Famous last words? *SCNR*

Thanks, Phil
