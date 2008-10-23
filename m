From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: Regression: Recent networking (qdisc?) patches break
 irda_get_next_speed()
Date: Thu, 23 Oct 2008 15:13:02 -0700
Message-ID: <F169D4F5E1F1974DBFAFABF47F60C10A069DFD1F@orsmsx507.amr.corp.intel.com>
References: <48FE1D52.6080903@ceibo.fiec.espol.edu.ec>
	<48FE2F81.9060801@gmail.com>	<48FE67D4.5060200@ceibo.fiec.espol.edu.ec>
 <20081021.164121.257737412.davem@davemloft.net>
 <48FFC438.1080505@ceibo.fiec.espol.edu.ec>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: =?iso-8859-1?Q?Alex_Villac=ED=ADs_Lasso?=
	<avillaci@ceibo.fiec.espol.edu.ec>,
	"irda-users@lists.sourceforge.net" <irda-users@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:49398 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751772AbYJWWNM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2008 18:13:12 -0400
In-Reply-To: <48FFC438.1080505@ceibo.fiec.espol.edu.ec>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alex Villac=ED=ADs Lasso wrote:
<snip>

>> The SKB control block is not aliased.
>>=20

=2E..
>> IRDA cannot depend upon the SKB control block not changing across
>> the dev_queue_xmit() call.=20
>>=20
>>=20
> Let me see if I understood. So the particular illegal thing the IRDA
> stack is doing is the access of the control block in the middle of th=
e
> driver transmit routine (via irda_get_next_speed() and friends). This
> information should be stored somewhere else. Exactly *where* to store
> it is the main problem to solve.
>=20
> What is the proper way (if any) to store per-packet parameters (other
> than the payload itself) which are specific to a particular layer
> (IrDA in this case) and which are needed by drivers in order to work
> correctly? The control block gets overwritten by the time the driver
> proc (hard_start_xmit) is called, so this approach is now ruled out. =
I
> was thinking about storing a copy of the parameters (struct
> irda_skb_cb) as a header within the payload itself (skb->data[]), but
> I am not sure about whether this approach is a good design decision.
> I am open to suggestions on where to place the parameters.

Isn't this what the data that is skb_reserve'd at the beginning of skb'=
s allocated by netdev_alloc_skb is for?  If you take an extra reference=
 to the skb and/or use a destructor hook you should be good, right?

you should just be able to push ->data using skb_reserve(sizeof your pr=
ivate data) in the beginning of the skb, or is that a horrible idea Dav=
e?
