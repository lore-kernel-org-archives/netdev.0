From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [RFC] Kernel unaligned access at __skb_flow_dissect
Date: Fri, 29 Jan 2016 18:04:24 -0500
Message-ID: <20160129230424.GG17127@oracle.com>
References: <20160129180651.GA17127@oracle.com>
 <1454092428.7627.52.camel@edumazet-glaptop2.roam.corp.google.com>
 <1454093642.7627.57.camel@edumazet-glaptop2.roam.corp.google.com>
 <CALx6S34+od6o69rHQzotJFXf7kziEuQUj=xH5VUWw+YpH4FjNg@mail.gmail.com>
 <20160129210900.GD17127@oracle.com>
 <CALx6S35V47scFFQab7ZsQyh6CktS17w4hSKZSVAnOB0Ppa7brg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Michael Dalton <mwdalton@google.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:44278 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751046AbcA2XEk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 18:04:40 -0500
Content-Disposition: inline
In-Reply-To: <CALx6S35V47scFFQab7ZsQyh6CktS17w4hSKZSVAnOB0Ppa7brg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (01/29/16 15:00), Tom Herbert wrote:

> The sparc documentation is pretty clear
> http://docs.oracle.com/cd/E19253-01/816-4854/hwovr-2/index.html, seems
> like unaligned accesses are not allowed in the architecture.

yes, but looks like you  can paper over some of this with
memcpy (as was happening with the saddr ref in skb_flow_dissect
that puzzled me and Eric because it did not generate any traps).

I suppose one could sprinkele a few WARN_ON's for !IS_ALIGNED
but that's not a fool-proof detection method either (in addition
to all the ugly shouting in the code).

--Sowmini
