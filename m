From: David Miller <davem@davemloft.net>
Subject: Re: MPLS for Linux kernel
Date: Tue, 22 Nov 2011 16:49:09 -0500 (EST)
Message-ID: <20111122.164909.156852889818363753.davem@davemloft.net>
References: <4ECBB2C4.9000505@dti2.net>
	<CAFdo_mUH=21_+xuLqE6tytHmD-QwXb9XXfTzixYFqUcbcLAfWQ@mail.gmail.com>
	<CAFdo_mVdva4=4bJOaXQTNHhD-3h5LSLvERi8D7s-45SdRO5ibA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: igorm@etf.rs
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54475 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752771Ab1KVVtQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 16:49:16 -0500
In-Reply-To: <CAFdo_mVdva4=4bJOaXQTNHhD-3h5LSLvERi8D7s-45SdRO5ibA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Igor Maravi=E6 <igorm@etf.rs>
Date: Tue, 22 Nov 2011 22:41:44 +0100

> I would like to know what is necesary for MPLS implementation to have=
,
> and to do, so it would be accepted in upstream kernel?

A long and laborious back and forth review process, taking into conside=
ration
not just the technical details of the patches themselves, but the top l=
evel
and overall design.

That's what it will take.

Taking someone else's work, fixing all the bugs and cleaning them up is
far from sufficient for a feature of this nature.  There is natural
overlap all over and we have to make sure the implementation bits are
going into the right places.

One issue of constant contention is that people want to add all of thei=
r
favorite packet filtering and packet mangling into their protocol handl=
ing
code, with all kinds of custom controls and configuration mechanisms.

WE HATE THIS.

We have the packet scheduler classifiers and packet actions for a reaso=
n,
and we want them to used instead of ignored.

We are going through the same thing in the review process for the openv=
switch
code, which brings up another design question for MPLS, which is whethe=
r MPLS
can be better implemented in terms of openvswitch.

You're in the unfortunate position of submitting a feature that has a
lot of overlap with many other subsystems, existing code, and features
being submitted at the same time.  We want as much reuse as possible,
and we want it all designed right before it gets integrated.

I frankly don't care very much about MPLS personally, it's such a
fringe facility.  So if people just argue themselves into oblivion and
no forward progress is made, just like last time an MPLS submission
was attempted, that's also fine with me :-)
