From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [net-next PATCH v3 00/12] Flow API
Date: Fri, 23 Jan 2015 12:39:34 +0100
Message-ID: <20150123113934.GD2065@nanopsycho.orion>
References: <20150122133713.GA25797@casper.infradead.org>
 <20150122140022.GA5674@salvia>
 <54C11094.2000807@mojatatu.com>
 <20150122151316.GB25797@casper.infradead.org>
 <54C11703.7030702@mojatatu.com>
 <20150122153727.GC25797@casper.infradead.org>
 <54C11ACC.5010005@mojatatu.com>
 <20150123101019.GF25797@casper.infradead.org>
 <20150123102421.GB2065@nanopsycho.orion>
 <20150123110821.GH25797@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	John Fastabend <john.fastabend@gmail.com>,
	simon.horman@netronome.com, sfeldma@gmail.com,
	netdev@vger.kernel.org, davem@davemloft.net, gerlitz.or@gmail.com,
	andy@greyhouse.net, ast@plumgrid.com
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:64264 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751337AbbAWLjh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 06:39:37 -0500
Received: by mail-we0-f174.google.com with SMTP id x3so7067596wes.5
        for <netdev@vger.kernel.org>; Fri, 23 Jan 2015 03:39:36 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20150123110821.GH25797@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Jan 23, 2015 at 12:08:21PM CET, tgraf@suug.ch wrote:
>On 01/23/15 at 11:24am, Jiri Pirko wrote:
>> I think that comparing this to team or routing userspace is not
>> correct. The reason is that team and routing has single api to kernel.
>> However in this case userspace has to use multiple APIs.
>
>The point I was trying to make is that there are legitimate reasons
>to keep complexity out of the kernel and team is a good example for
>that.
>
>As for multiple APIs. Team does in fact export its own Generic Netlink
>interface while it also hooks into rtnetlink to support ip link. Not
>sure whether that qualifies for multiple APIs or not but I think it's
>an excellent architecture decision. Same as for nl80211 tools.

Team uses multiple api for sure, but for different things.

>
>> For example OVS. It would have to use existing OVS gennetlink iface + this
>> new flow netlink iface for flow offloads. For all others, this is the same.
>> Multiple apis for the same thing (does not matter if it is implemented
>> in hw or sw) does not seem right to me.
>
>Fair enough. I have no objections to merging the flow API into RTNETLINK
>although I don't really see a need to put more under the rtnl umbrella
>unless absolutely required.
>
>I think John also mentioned that he proposes to have this as a separate
>Generic Netlink interface for now but this could really live wherever it
>seems appropriate.

Maybe I did not express myself correctly. I do not care if this is
exposed by rtnl or a separate genetlink. The issue still stands. And the
issue is that the user have to use "the way A" to setup sw datapath and
"the way B" to setup hw datapath. The preferable would be to have
"the way X" which can be used to setup both sw and hw.

And I believe that could be achieved. Consider something like this:

- have cls_xflows tc classifier and act_xflows tc action as a wrapper
  (or api) for John's work. With possibility for multiple backends. The
  backend iface would looke very similar to what John has now.
- other tc clses and acts will implement xflows backend
- openvswitch datapath will implement xflows backend
- rocker switch will implement xflows backend
- other drivers will implement xflows backend

Now if user wants to manipulate with any flow setting, he can just use
cls_xflows and act_xflows to to that.

This is very rough, but I just wanted to draw the picture. This would
provide single entry to flow world manipulation in kernel, no matter if
sw or hw.

Thoughts?
