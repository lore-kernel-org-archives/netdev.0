From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: Problems obtaining software TX timestamps
Date: Thu, 9 Sep 2010 19:32:28 +0200
Message-ID: <20100909173228.GA2657@riccoc20.at.omicron.at>
References: <4C877D8A.6040002@edu.uni-klu.ac.at>
 <1283958771.2748.85.camel@edumazet-laptop>
 <4C87FE60.7090209@edu.uni-klu.ac.at>
 <20100909063541.GA3305@riccoc20.at.omicron.at>
 <4C889A1E.6050405@edu.uni-klu.ac.at>
 <20100909135716.GA8706@riccoc20.at.omicron.at>
 <1284040958.2589.178.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Kofler <ikofler@edu.uni-klu.ac.at>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:43339 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751800Ab0IIRcj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Sep 2010 13:32:39 -0400
Received: by bwz11 with SMTP id 11so1334314bwz.19
        for <netdev@vger.kernel.org>; Thu, 09 Sep 2010 10:32:38 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1284040958.2589.178.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 09, 2010 at 04:02:38PM +0200, Eric Dumazet wrote:
> Should drivers call it at start_xmit() time, or at tx completion time ?

If I could tell you that, I could also describe the sound of one hand
clapping.

IMHO, it should be done as immediately after the buffer has been
handed off to the hardware. Not all MACs have a completion method, so
that would at least make the "rule" consistent.

In general, the goals of high volume and timestamp accuracy are in
conflict (unless you have HW timestamping). If users are relying on SW
timestamping, then they should be aware of the fact that high network
traffic will spoil their fun.

Having said that, I don't know enough about all the different kinds of
MACs out there to really answer the question definitively.

Richard
