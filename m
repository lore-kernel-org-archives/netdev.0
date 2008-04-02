From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH net-2.6.26] netlink: make socket filters work on netlink
Date: Wed, 02 Apr 2008 09:10:52 -0400
Message-ID: <1207141852.4451.181.camel@localhost>
References: <47EAAFEC.6000805@trash.net> <20080331123311.64e4ca37@extreme>
	 <47F13E43.2040404@trash.net>
	 <20080331.130757.199769025.davem@davemloft.net>
	 <47F1467F.2080407@trash.net> <1207000143.4424.167.camel@localhost>
	 <47F22211.5080100@trash.net> <1207058646.4424.218.camel@localhost>
	 <47F35933.5080305@trash.net>  <20080402112103.GB20815@postel.suug.ch>
	 <1207137667.4451.143.camel@localhost>  <47F37762.2030705@trash.net>
	 <1207139106.4451.155.camel@localhost>  <47F38002.70005@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.238]:60819 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754369AbYDBNK6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2008 09:10:58 -0400
Received: by wx-out-0506.google.com with SMTP id h31so2840215wxd.4
        for <netdev@vger.kernel.org>; Wed, 02 Apr 2008 06:10:56 -0700 (PDT)
In-Reply-To: <47F38002.70005@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-02-04 at 14:45 +0200, Patrick McHardy wrote:

> Mhh .. we could use a magic nlmsg_pid value (just like zero)
> to indicate it was done on behalf of a process using ioctls or
> some other, non-netlink means. 

In my experience attempting to write user space apps which worry about
whodunnit and filtering in user space (essentially solving similar
problem to what Stephen is attempting to), this non-nl paths have been
the most headache. Every book written on linux network config
demonstrates ifconfig and route utilities. Of course you could put
restrictions with caveats like "my app works only if you used ip or used
ifconfig version 3 which uses netlink" - but that puts a damp in the
whole concept.

> I'm wondering how useful this
> (or any other "whodunit" identifier) would be for filtering
> though, I think you're usually more interested in certain
> objects than certain processes, like all routes to 192.168.0.0/16,
> no matter who changes them.

I think both are of interest.
Historically in routes for example, the interest would be apps/processes
(not direct mapping to processids) that are of interest (eg a route
added by OSPF vs one added by RIP etc). Filtering is done in user space
so you dont repropagate routes added by the "OSPF process" to RIP if
policy says so etc.
That of course has evolved to application name (gated vs zebra vs bird
etc) which implements all of OSPF/RIP/BGP etc and can keep track of
things. Theres further evolution which desires to run multiple instances
of quagga on the same machine etc.
I dont think the processid is the right thing, but some 32 bit id which
maps to a name would be useful or even a static field defined in some
header file. The name serving could be out of the kernel for simplicity
if the process dies and is re-incarnated it knows what to read(some of
these ideas are already in genetlink).

> Unfortunately we can't add a new field to the existing headers
> without breaking things, so anything new would likely be subsystem
> specific.

Agreed, it is a bit too late to change netlink without breaking apps
(and reason i was suggesting i was going to add it to actions/cls).
Essentially even in subsystem specifics it would be an attribute
(transported via TLV).

cheers,
jamal

