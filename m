From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [patch net-next v2 1/3] team: handle sending port list in the
 same way option list is sent
Date: Tue, 5 Feb 2013 01:28:43 +0100
Message-ID: <20130205002842.GA11589@localhost>
References: <1359742646-1485-1-git-send-email-jiri@resnulli.us>
 <1359742646-1485-2-git-send-email-jiri@resnulli.us>
 <20130201183045.GA5822@localhost>
 <20130201190026.GA1627@minipsycho.brq.redhat.com>
 <20130201204310.GA3793@localhost>
 <20130201233147.GB1627@minipsycho.brq.redhat.com>
 <20130202012927.GA4425@localhost>
 <20130202090422.GA1864@minipsycho.orion>
 <20130204160303.GA22732@localhost>
 <20130204162806.GA1544@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, fbl@redhat.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from slan-550-85.anhosting.com ([174.127.110.175]:13247 "EHLO
	slan-550-85.anhosting.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754431Ab3BEA2u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2013 19:28:50 -0500
Content-Disposition: inline
In-Reply-To: <20130204162806.GA1544@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 04, 2013 at 05:28:06PM +0100, Jiri Pirko wrote:
> Mon, Feb 04, 2013 at 05:03:04PM CET, pablo@netfilter.org wrote:
> >On Sat, Feb 02, 2013 at 10:04:22AM +0100, Jiri Pirko wrote:
[...]
> >> Messages are too big to fit one GENLMSG_DEFAULT_SIZE message.
> >
> >nfnetlink_log may use bigger messages than 1 memory page to deliver
> >multicast events if configured to include the entire packet
> >(NFULNL_COPY_PACKET).
> >
> >I'd suggest to calculate the message size in run-time and allocate
> >memory you need according to that, several netfilter subsystem are
> >doing so.
> 
> I recall I had some issues with longer messages on the userspace part,
> I'm not sure what that was exactly.

Hm, it should be OK.

> I decided to do this in multipart messages and in order to do not
> break userspace I would like to continue to do so.

It was just a suggestion.

Note that fitting the message in one single skb should also simplify
the handling in case you hit ENOBUFS from user-space. But you know
better your needs for the team driver, I leave this up to you.
