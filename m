From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [DCCP] [RFC] [Patchv2 1/1]: Queuing policies -- reworked
	version of Tomasz's patch set
Date: Wed, 16 Apr 2008 08:43:25 +0100
Message-ID: <20080416074325.GC4278@gerrit.erg.abdn.ac.uk>
References: <200804111224.06958.tomasz@grobelny.oswiecenia.net> <200804150145.05571.tomasz@grobelny.oswiecenia.net> <20080415151403.GA20735@gerrit.erg.abdn.ac.uk> <200804152138.41077.tomasz@grobelny.oswiecenia.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
To: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:35787 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750847AbYDPHnw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Apr 2008 03:43:52 -0400
Content-Disposition: inline
In-Reply-To: <200804152138.41077.tomasz@grobelny.oswiecenia.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Tomasz Grobelny:
| Dnia Tuesday 15 of April 2008, Gerrit Renker napisa?:
| > | > @@ -501,6 +519,8 @@ struct dccp_sock {
| > | >  	struct ccid			*dccps_hc_rx_ccid;
| > | >  	struct ccid			*dccps_hc_tx_ccid;
| > | >  	struct dccp_options_received	dccps_options_received;
| > | > +	__u8				dccps_qpolicy;
| > | > +	__u32				dccps_tx_qlen;
| > | >  	enum dccp_role			dccps_role:2;
| > | >  	__u8				dccps_hc_rx_insert_options:1;
| > | >  	__u8				dccps_hc_tx_insert_options:1;
| > |
| > | I know that currently none of the policies has any per-socket dat=
a. But
| > | if it had were should it go?
| >
| > I can't see anything wrong with putting everything into dccp_sock. =
To do it
| > well, we could consider inserting documentation such as "this secti=
on is
| > only for queueing policies" (as is done very well for struct tcp_so=
ck).
| >
| Let me remind you your comment made on 18/03/2008 on dccp ml to my fi=
rst=20
| patch:
|  --- START ---=20
| @@ -545,6 +549,8 @@ struct dccp_sock {
| =A0 =A0 =A0 =A0 __u8 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0dccps_hc_tx_insert_options:1;
| =A0 =A0 =A0 =A0 __u8 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0dccps_server_timewait:1;
| =A0 =A0 =A0 =A0 struct timer_list =A0 =A0 =A0 =A0 =A0 =A0 =A0 dccps_x=
mit_timer;
| + =A0 =A0 =A0 struct queuing_policy =A0 =A0=A0=A0=A0=A0=A0=A0=A0*dccp=
s_policy;
| + =A0 =A0 =A0 void =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0*dccps_policy_data;
| =A0};
|=20
| I think this should be just one field for the policy, and the
| policy_data can be an internal field of `struct queueing_policy'
| (compare with struct ackvec or struct ccid).
|  --- END ---=20
|=20
Hm, even after reading it again I still find that I don't like void* fi=
elds. It
may be a personal thing, but I think using void* as part of a field is =
bad (and
this was in an even earlier comment).

I think I understand your approach better now, after going through the
patches again.


| Ok, you are right. If before DCCP_LISTENING there is always DCCP_CLOS=
ED then=20
| there is no need to allow changing qpolicy in DCCP_LISTENING state.
|=20
Yes, that's right -- the initial state is always DCCP_CLOSED, set in
dccp_init_sock().


The University of Aberdeen is a charity registered in Scotland, No SC01=
3683.

