From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [DCCP] [RFC] [Patchv2 1/1]: Queuing policies -- reworked
	version of Tomasz's patch set
Date: Thu, 17 Apr 2008 19:29:35 +0100
Message-ID: <20080417182935.GB17054@gerrit.erg.abdn.ac.uk>
References: <200804111224.06958.tomasz@grobelny.oswiecenia.net> <200804152138.41077.tomasz@grobelny.oswiecenia.net> <20080416074325.GC4278@gerrit.erg.abdn.ac.uk> <200804172003.04480.tomasz@grobelny.oswiecenia.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
To: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:54601 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1763206AbYDQSaV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Apr 2008 14:30:21 -0400
Content-Disposition: inline
In-Reply-To: <200804172003.04480.tomasz@grobelny.oswiecenia.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| > | @@ -545,6 +549,8 @@ struct dccp_sock {
| > | =A0 =A0 =A0 =A0 __u8 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0dccps_hc_tx_insert_options:1;
| > | =A0 =A0 =A0 =A0 __u8 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0dccps_server_timewait:1;
| > | =A0 =A0 =A0 =A0 struct timer_list =A0 =A0 =A0 =A0 =A0 =A0 =A0 dcc=
ps_xmit_timer;
| > | + =A0 =A0 =A0 struct queuing_policy =A0 =A0=A0=A0=A0=A0=A0=A0=A0*=
dccps_policy;
| > | + =A0 =A0 =A0 void =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0*dccps_policy_data;
| > | =A0};
| > |
| > | I think this should be just one field for the policy, and the
| > | policy_data can be an internal field of `struct queueing_policy'
| > | (compare with struct ackvec or struct ccid).
| > |  --- END ---
| >
| > Hm, even after reading it again I still find that I don't like void=
*
| > fields. It may be a personal thing, but I think using void* as part=
 of a
| > field is bad (and this was in an even earlier comment).
| >
| The next paragraph was in fact about void* pointers. But the paragrap=
h I=20
| quoted above talks only about whether those three values (policy=20
| numer/pointer, tx_qlen and possibly other data) should be put directl=
y in=20
| struct dccp_sock or grouped in stuct queueing_policy which in turn sh=
ould be=20
| one field in struct dccp_sock. In the mail from 18/03/2008 you seemed=
 to be=20
| in favour of grouping, in the one from 15/04/2008 you seemed to contr=
adict=20
| your earlier statement. At least that's how I understood it.
| But never mind, both ways are ok for me.
| --=20
Those things only became clearer when looking at the code for a while. =
I
have reworked some of your userland code and done some tests with it.

There was a bug with the 32-bit compatibility layer, I have posted a
message to netdev. On x86 it was found to work correctly.


The University of Aberdeen is a charity registered in Scotland, No SC01=
3683.

