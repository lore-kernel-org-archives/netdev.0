From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-2.6.26] netlink: make socket filters work on netlink
Date: Wed, 02 Apr 2008 14:45:54 +0200
Message-ID: <47F38002.70005@trash.net>
References: <47EAAFEC.6000805@trash.net> <20080331123311.64e4ca37@extreme>	 <47F13E43.2040404@trash.net>	 <20080331.130757.199769025.davem@davemloft.net>	 <47F1467F.2080407@trash.net> <1207000143.4424.167.camel@localhost>	 <47F22211.5080100@trash.net> <1207058646.4424.218.camel@localhost>	 <47F35933.5080305@trash.net>  <20080402112103.GB20815@postel.suug.ch>	 <1207137667.4451.143.camel@localhost>  <47F37762.2030705@trash.net> <1207139106.4451.155.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64352 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756114AbYDBMqC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2008 08:46:02 -0400
In-Reply-To: <1207139106.4451.155.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jamal wrote:
> On Wed, 2008-02-04 at 14:09 +0200, Patrick McHardy wrote:
> 
>> Yes, but it was the use of current->pid that was wrong.
> 
> There are many many apps out there which still use ioctls - hence the
> ambiguity of "is it the kernel that generated the command that caused
> the event or was it merely a proxy for some app". 
> You need to resolve that. 

Mhh .. we could use a magic nlmsg_pid value (just like zero)
to indicate it was done on behalf of a process using ioctls or
some other, non-netlink means. I'm wondering how useful this
(or any other "whodunit" identifier) would be for filtering
though, I think you're usually more interested in certain
objects than certain processes, like all routes to 192.168.0.0/16,
no matter who changes them.

>> If one of those calls are in a path invoked through netlink
>> it should set nlmsg_pid.
> 
> Nod - I think thats mostly taken care of; havent looked lately. I know
> Alexey didnt object to any patches i submitted that did change how
> nlmsg_pid was set on events to match this thought and I cant think of a
> reason it would violate any netlink ettiquette. 
> 
> Note, I find the whoddunit field (not the pid) to be also useful for
> aesthetics and debugging other than for the non-ambiguity in the
> filtering.

Unfortunately we can't add a new field to the existing headers
without breaking things, so anything new would likely be subsystem
specific.

