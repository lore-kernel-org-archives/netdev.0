From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2.6.23+] ingress classify to [nf]mark
Date: Mon, 14 Jan 2008 07:56:12 -0500
Message-ID: <1200315372.4427.75.camel@localhost>
References: <47866C69.3080904@bspu.unibel.by>
	 <1200001167.4443.38.camel@localhost>  <4787A663.4030204@bspu.unibel.by>
	 <1200063541.4483.42.camel@localhost>  <4787D49E.6080906@bspu.unibel.by>
	 <1200107027.4477.36.camel@localhost>  <4788FF45.702@bspu.unibel.by>
	 <1200253484.4427.33.camel@localhost>  <478B8250.90602@bspu.unibel.by>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mahatma@eu.by
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.234]:41972 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750708AbYANM4Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 07:56:25 -0500
Received: by wx-out-0506.google.com with SMTP id h31so1043372wxd.4
        for <netdev@vger.kernel.org>; Mon, 14 Jan 2008 04:56:25 -0800 (PST)
In-Reply-To: <478B8250.90602@bspu.unibel.by>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-14-01 at 13:40 -0200, Dzianis Kahanovich wrote:
> jamal wrote:

> Yes, I only do it by inertia after "#define tc_index mark".

And i am afraid this bothers me greatly.
You already have ways to achieve what you need by setting proper policy,
the difference in configuration is an extra one policy line you have to
type in. Adding yet another #ifdef is really going overboard.

> I not understand why "tc_index" changed in this place. 1) there are ingress 2) 
> there are "OK" action. Are "tc_index" will not changed after: "tc filter add 
> dev eth0 parent ffff: ... flowid 1:1 action continue" ? In general - are 
> tc_index useful in ingress? (may be tc_index used in [nf]mark-style, but even 
> in netfilter it feature migrate - IMHO, may be I time to time do not see in 
> needed place)

tc_index could be used for classification actually. If you "continue"
you could hit another classifier which looks at it.

> Sorry, I just change focus from existing "tc_index=..." to common behaviour ;)

> [...]
> > Please refer to what i said above; if what i said still doesnt make
> > sense i can create (the simple) patch.
> 
> A bit vague... sorry...

I mean:

#ifdef CONFIG_NET_CLS_ACT
.... leave this part alone which already sets tc_index ...
#else
...set tc_index and mark here ...
#endif

And when we have a metadata action - we remove setting of tc_index from
#ifdef CONFIG_NET_CLS_ACT

Did that make sense?

cheers,
jamal

