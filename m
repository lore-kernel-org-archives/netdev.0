From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: VLAN HW accel, performance advantage?
Date: Tue, 3 Sep 2013 15:48:16 +0100
Message-ID: <1378219696.1545.9.camel@bwh-desktop.uk.level5networks.com>
References: <OF00E35E7C.7482EC01-ONC1257BDB.00314AD0-C1257BDB.0031F6D0@transmode.se>
	 <1378216216.1545.1.camel@bwh-desktop.uk.level5networks.com>
	 <OF0F246C2A.B5DC5CA4-ONC1257BDB.004CA4E6-C1257BDB.004DB31E@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:50511 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753420Ab3ICOsU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 10:48:20 -0400
In-Reply-To: <OF0F246C2A.B5DC5CA4-ONC1257BDB.004CA4E6-C1257BDB.004DB31E@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-09-03 at 16:08 +0200, Joakim Tjernlund wrote:
> Ben Hutchings <bhutchings@solarflare.com> wrote on 2013/09/03 15:50:16:
> > 
> > On Tue, 2013-09-03 at 11:05 +0200, Joakim Tjernlund wrote:
> > > I am considering impl. VLAN HW acceleration in Freescales ucc_geth 
> driver 
> > > to improve
> > > performance, primarily for bridged interfaces.
> > >  I am hoping the community has some insights as to what performance 
> gains 
> > > one
> > > could expect?
> > 
> > At the moment you need to do VLAN RX offload (or fake it in software) to
> > take advantage of GRO for VLAN-encapsulated packets.  Other than that, I
> > don't think it makes a lot of difference in most situations.
> > 
> > Ben.
> 
> Thanks Ben
> 
> I figured one would avoid some memmoves if the tag was extracted and as we 
> got
> a fairly slow CPU (some 300 MHZ MPC 8321) one should gain some performance 
> but not so then.

Of course it will avoid some memmoves, I just don't think that makes
much of a difference any more.  There used to be other more major
performance issues (like having to copy packets) but I believe they've
been fixed in the stack now.

> I am not familiar with GRO( and its friends) but I am guessing it won't 
> help
> the bridge function or reduce stress from packet storms?

GRO should be beneficial for bridges if you have bursty TCP streams.  It
is especially beneficial if you also have TSO on the TX side.

Really you're going to have to try it and run benchmarks with your own
hardware.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
