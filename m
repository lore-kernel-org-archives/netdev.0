From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Subject: Re: [DCCP] [RFC] [Patchv2 1/1]: Queuing policies -- reworked version of Tomasz's patch set
Date: Thu, 17 Apr 2008 20:03:04 +0200
Message-ID: <200804172003.04480.tomasz@grobelny.oswiecenia.net>
References: <200804111224.06958.tomasz@grobelny.oswiecenia.net> <200804152138.41077.tomasz@grobelny.oswiecenia.net> <20080416074325.GC4278@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	dccp@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from oswiecenia.net ([83.13.108.58]:4525 "EHLO poczta.oswiecenia.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934775AbYDQSDr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Apr 2008 14:03:47 -0400
In-Reply-To: <20080416074325.GC4278@gerrit.erg.abdn.ac.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dnia Wednesday 16 of April 2008, Gerrit Renker napisa=B3:
> Quoting Tomasz Grobelny:
> | Dnia Tuesday 15 of April 2008, Gerrit Renker napisa?:
> | > | > @@ -501,6 +519,8 @@ struct dccp_sock {
> | > | >  	struct ccid			*dccps_hc_rx_ccid;
> | > | >  	struct ccid			*dccps_hc_tx_ccid;
> | > | >  	struct dccp_options_received	dccps_options_received;
> | > | > +	__u8				dccps_qpolicy;
> | > | > +	__u32				dccps_tx_qlen;
> | > | >  	enum dccp_role			dccps_role:2;
> | > | >  	__u8				dccps_hc_rx_insert_options:1;
> | > | >  	__u8				dccps_hc_tx_insert_options:1;
> | > |
> | > | I know that currently none of the policies has any per-socket d=
ata.
> | > | But if it had were should it go?
> | >
> | > I can't see anything wrong with putting everything into dccp_sock=
=2E To
> | > do it well, we could consider inserting documentation such as "th=
is
> | > section is only for queueing policies" (as is done very well for =
struct
> | > tcp_sock).
> |
> | Let me remind you your comment made on 18/03/2008 on dccp ml to my =
first
> | patch:
> |  --- START ---
> | @@ -545,6 +549,8 @@ struct dccp_sock {
> | =A0 =A0 =A0 =A0 __u8 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0dccps_hc_tx_insert_options:1;
> | =A0 =A0 =A0 =A0 __u8 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0dccps_server_timewait:1;
> | =A0 =A0 =A0 =A0 struct timer_list =A0 =A0 =A0 =A0 =A0 =A0 =A0 dccps=
_xmit_timer;
> | + =A0 =A0 =A0 struct queuing_policy =A0 =A0=A0=A0=A0=A0=A0=A0=A0*dc=
cps_policy;
> | + =A0 =A0 =A0 void =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0*dccps_policy_data;
> | =A0};
> |
> | I think this should be just one field for the policy, and the
> | policy_data can be an internal field of `struct queueing_policy'
> | (compare with struct ackvec or struct ccid).
> |  --- END ---
>
> Hm, even after reading it again I still find that I don't like void*
> fields. It may be a personal thing, but I think using void* as part o=
f a
> field is bad (and this was in an even earlier comment).
>
The next paragraph was in fact about void* pointers. But the paragraph =
I=20
quoted above talks only about whether those three values (policy=20
numer/pointer, tx_qlen and possibly other data) should be put directly =
in=20
struct dccp_sock or grouped in stuct queueing_policy which in turn shou=
ld be=20
one field in struct dccp_sock. In the mail from 18/03/2008 you seemed t=
o be=20
in favour of grouping, in the one from 15/04/2008 you seemed to contrad=
ict=20
your earlier statement. At least that's how I understood it.
But never mind, both ways are ok for me.
--=20
Regards,
Tomasz Grobelny
