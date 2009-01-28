From: "Paul Moore" <paul.moore@centrify.com>
Subject: RE: port bound SAs
Date: Wed, 28 Jan 2009 10:27:09 -0800
Message-ID: <BB7E16A14DE689469A181EC770AFBF4D02A7775E@exch-one.centrify.com>
References: <F82446300569AC408EF6BC9E358737947EC12368@exch-one.centrify.com>	<BB7E16A14DE689469A181EC770AFBF4D02A773C1@exch-one.centrify.com> <20090126.222035.100955508.davem@davemloft.net> <497EE171.1030907@trash.net> <BB7E16A14DE689469A181EC770AFBF4D02A77515@exch-one.centrify.com> <497F3DD0.5010502@trash.net> <BB7E16A14DE689469A181EC770AFBF4D02A77722@exch-one.centrify.com> <49809DD5.6080104@trash.net> <BB7E16A14DE689469A181EC770AFBF4D02A7774E@exch-one.centrify.com> <49809FE8.2040801@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.centrify.com ([216.112.107.103]:42270 "EHLO
	exch-one.centrify.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751981AbZA1S1J convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 13:27:09 -0500
Content-class: urn:content-classes:message
In-Reply-To: <49809FE8.2040801@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

aha - so with racoon (which uses pfkey) I cannot make this work

This kind of seems broken - doesnt it? racoon is a very common IKE
daemon

So what IKE daemon should I be using on linux?

FYI

On solaris they do 2367 it differently (I know this because I am in the
middle of porting racoon to solaris)

the ACQUIRE message to user land has port selectors in it (linux does
not, and racoon accidentaly barfs if they are there)
the ADD and UPDATE messages from user land contain selectors and the
kernel expects them (racoon leaves them set randomly, fortunately Linux
pfkey throws them away)

This is why solaris does the right thing in terms of wire behavior. Its
selector code know about ports (using its own IKE daemon)

The simple solution is to stop the pfkey interface throwing the port
numbers away and then I can change racoon to send them (which I had to
do for solaris port)



-----Original Message-----
From: Patrick McHardy [mailto:kaber@trash.net] 
Sent: Wednesday, January 28, 2009 10:12 AM
To: Paul Moore
Cc: David Miller; netdev@vger.kernel.org
Subject: Re: port bound SAs

Paul Moore wrote:
> So how do I get an SA with a port set on it

You don't, using pfkey. Use reqid or ip xfrm.
