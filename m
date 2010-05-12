From: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Subject: Re: get beyond 1Gbps with pktgen on 10Gb nic?
Date: Tue, 11 May 2010 21:51:08 -0700
Message-ID: <AANLkTilZseWJCHnDXSjwUYol7ewXewIhMJG-tqWO_C86@mail.gmail.com>
References: <4A6A2125329CFD4D8CC40C9E8ABCAB9F2497D752C7@MILEXCH2.ds.jdsu.net>
	 <1273584925.2107.6.camel@achroite.uk.solarflarecom.com>
	 <4BE97DD7.7000704@candelatech.com>
	 <4A6A2125329CFD4D8CC40C9E8ABCAB9F2497D85C81@MILEXCH2.ds.jdsu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Ben Greear <greearb@candelatech.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jon Zhou <Jon.Zhou@jdsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:39115 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750921Ab0ELEvK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 May 2010 00:51:10 -0400
Received: by gyg13 with SMTP id 13so3165108gyg.19
        for <netdev@vger.kernel.org>; Tue, 11 May 2010 21:51:08 -0700 (PDT)
In-Reply-To: <4A6A2125329CFD4D8CC40C9E8ABCAB9F2497D85C81@MILEXCH2.ds.jdsu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 11, 2010 at 9:00 PM, Jon Zhou <Jon.Zhou@jdsu.com> wrote:
> I just used multi netperf instances to reach 900K pps/8Gb+ traffic on the Broadcom 10G nic:
>
> command:
>
> for i in 1 2 3 4 5 6 7 8 9 10
> do
> netperf -l 60 -H 192.168.0.53 -- -m 60 -s 100M -S 100M &
> done
>
> the msg size was assigned as 64 bytes, but when I checked the file captured by tcpdump,
> found that netperf sent many frames which are large than 64 bytes(i.e.4000-10K+ bytes) and these frames
> were truncated by tcpdump.
>
> so that the actual avg packet size is around 1500 bytes, but what I want is avg packet: 300-400 bytes and reach 5Gb+.
>
> does it make sense?

if you set the TCP_NODELAY (to disable nagle) option on netperf (check
netperf -t TCP_STREAM -- -h) then you should be able to control packet
size.
