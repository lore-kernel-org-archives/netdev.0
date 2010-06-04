From: Patrick McHardy <kaber@trash.net>
Subject: Re: no reassembly for outgoing packets on RAW socket
Date: Fri, 04 Jun 2010 14:03:17 +0200
Message-ID: <4C08EB85.3050900@trash.net>
References: <20100604112708.GA1958@jolsa.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jiri Olsa <jolsa@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49471 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751745Ab0FDMDU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jun 2010 08:03:20 -0400
In-Reply-To: <20100604112708.GA1958@jolsa.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Olsa wrote:
> hi,
> 
> I'd like to be able to sendout a single IP packet with MF flag set.
> 
> When using RAW sockets the packet will get stuck in the
> netfilter (NF_INET_LOCAL_OUT nf_defrag_ipv4 reassembly unit)
> and wont ever make it out..
> 
> I made a change which bypass the outgoing reassembly for
> RAW sockets, but I'm not sure wether it's too invasive..

That would break reassembly (and thus connection tracking) for cases
where its really intended.

> Is there any standard for RAW sockets behaviour?
> Or another way around? :)

You could use the NOTRACK target to bypass connection tracking.
