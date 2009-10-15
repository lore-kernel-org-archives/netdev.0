From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: query: bnx2 and tg3 don't check tcp and/or ip header length validity?
Date: Wed, 14 Oct 2009 20:40:36 -0400
Message-ID: <4AD66F84.2010703@gmail.com>
References: <4AD5F333.3040002@gmail.com>  <4AD638AC.3000901@gmail.com> <1255555458.20869.221.camel@nseg_linux_HP1.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.25]:46056 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762238AbZJOAlp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2009 20:41:45 -0400
Received: by qw-out-2122.google.com with SMTP id 9so115689qwb.37
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2009 17:40:39 -0700 (PDT)
In-Reply-To: <1255555458.20869.221.camel@nseg_linux_HP1.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael Chan wrote:
> The option length is needed by the hardware to segment a TSO packet into
> proper MTU-sized packets.  You'll get malformed packets if the TSO
> header is bad.  Setting it to zero perhaps can make these bad packets
> more deterministic, but I don't know for sure.
> 
Malformed packets are unlikely (I'll use unlikely() on the test), but
I've seen a lot of unlikely things happen over the years.  When I was
concourse manager at Interop '91, a bad Portmaster build wouldn't pass
packets through one kind of router (3com); but it passed through all
the others!  Turned out, *most* routers didn't check the IP version
and IHL fields.  Shocking!

When we were designing IPv6 in '93, we had to use new IEEE numbers, etc.
(instead of the IP version and IHL) to distinguish the new version.
Otherwise, various printers crashed....

Unless there's a clearly documented check earlier in the code path (and
there's nothing documented here), always re-check everything.  (Also,
never forget cosmic radiation....)  Remember, from a driver developer's
perspective, the hardware always fails.  (And from a hardware viewpoint,
the software is always bad.)
