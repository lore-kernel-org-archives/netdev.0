From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [net-next PATCH v1 01/11] net: flow_table: create interface for
 hw match/action tables
Date: Mon, 5 Jan 2015 21:48:38 +0000
Message-ID: <20150105214838.GB31637@casper.infradead.org>
References: <20141231194057.31070.5244.stgit@nitbit.x32>
 <20141231194544.31070.30335.stgit@nitbit.x32>
 <20150104111238.GD15305@casper.infradead.org>
 <54AADEFF.3090306@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sfeldma@gmail.com, jiri@resnulli.us, jhs@mojatatu.com,
	simon.horman@netronome.com, netdev@vger.kernel.org,
	davem@davemloft.net, andy@greyhouse.net
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:49441 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751452AbbAEVsj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 16:48:39 -0500
Content-Disposition: inline
In-Reply-To: <54AADEFF.3090306@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/05/15 at 10:59am, John Fastabend wrote:
> On 01/04/2015 03:12 AM, Thomas Graf wrote:
> >On 12/31/14 at 11:45am, John Fastabend wrote:
> >
> >Impressive work John, some minor nits below. In general this looks
> >great. How large could tables grow? Any risk one of the nested
> >attribtues could exceed 16K in size because of a very large parse
> >graph? Not a problem if we account for it and allow for jumbo
> >attributes.
> >
> 
> hmm it sounds large to me but maybe if you have an NPU that is trying
> to parse into application data it could happen.
> 
> What does it take to allow for jumbo attributes?

We basically need to make user space aware of a new nlattr header
to be expected for certain attributes. We can reserve the 2nd bit
of the type to indicate a 32bit length field following the current
header. We can only do this for new attributes as its not backwards
compatible so we need to think about this before we start exposing
them.

I can send a patch introducing them in the next few days if you
want as it seems you'll have to respin this again anyway.

> >You can jump to hdr_put_failure right away and get rid of the
> >attr_put_failure target as you cancel that nest anyway. You can apply
> >this comment to several other places as well if you want.
> >
> 
> OK so to simplify the error paths we only need to cancel the outer most
> nested attribute. I'll do this transformation.

It's a matter of style. I'm fine either way. Personally I prefer the
single abort error target.
