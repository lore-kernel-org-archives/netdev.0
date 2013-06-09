From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [Patch net-next v3 1/3] igmp: fix return value of some functions
Date: Sat, 8 Jun 2013 20:12:41 -0600
Message-ID: <OF76532841.5DDD0996-ON87257B85.000C25DF-87257B85.000C25E6@us.ibm.com>
References: <1370689003.868.3.camel@cr0>,
	<1370485211-11498-1-git-send-email-amwang@redhat.com>	 <OFF0DFA533.AF670FB8-ON85257B82.006E0B5C-85257B82.006F58EF@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev-owner@vger.kernel.org, netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:33343 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751281Ab3FICMv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Jun 2013 22:12:51 -0400
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Sat, 8 Jun 2013 22:12:48 -0400
In-Reply-To: <1370689003.868.3.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>From: Cong Wang <amwang@redhat.com>

>   Good point! I will convert the such return value to
>documented ones, for example, EINVAL.  Thanks!

You're also taking things that were not treated as errors
before, and now returning an error. For example, removing
a source not in the list.

Unless POSIX requires these to be treated as errors, and
that should be quoted, I think the 8 or 9 years of returning
"0" for these cases means we must continue to. Existing
programs that have always done this with a zero return
will start getting errors where they didn't before.

Also, though it's been a long time, I believe the original code
did return errors in those cases (which is why the code is there)
and was changed to return 0, presumably for POSIX compliance.

What I'm really saying is: before you change user-visible
API, you should make the case that it is incorrect
according to the standard it follows. It isn't clear to me
that the original code is incorrect to treat those as
not error cases.

=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 +-DL=
S
