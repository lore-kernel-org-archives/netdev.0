From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [net-next PATCH v3 00/12] Flow API
Date: Fri, 23 Jan 2015 14:07:24 +0000
Message-ID: <20150123140724.GJ25797@casper.infradead.org>
References: <20150122151316.GB25797@casper.infradead.org>
 <54C11703.7030702@mojatatu.com>
 <20150122153727.GC25797@casper.infradead.org>
 <54C11ACC.5010005@mojatatu.com>
 <20150123101019.GF25797@casper.infradead.org>
 <20150123102421.GB2065@nanopsycho.orion>
 <20150123110821.GH25797@casper.infradead.org>
 <20150123113934.GD2065@nanopsycho.orion>
 <20150123122838.GI25797@casper.infradead.org>
 <20150123134315.GF2065@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	John Fastabend <john.fastabend@gmail.com>,
	simon.horman@netronome.com, sfeldma@gmail.com,
	netdev@vger.kernel.org, davem@davemloft.net, gerlitz.or@gmail.com,
	andy@greyhouse.net, ast@plumgrid.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:47146 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753317AbbAWOH3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 09:07:29 -0500
Content-Disposition: inline
In-Reply-To: <20150123134315.GF2065@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/23/15 at 02:43pm, Jiri Pirko wrote:
> Fri, Jan 23, 2015 at 01:28:38PM CET, tgraf@suug.ch wrote:
> >If I understand this correctly then you propose to do the decision on
> >whether to implement a flow in software or offload it to hardware in the
> >xflows classifier and action. I had exactly the same architecture in mind
> >initially when I first approached this and wanted to offload OVS
> >datapath flows transparently to hardware.
> 
> Think about xflows as an iface to multiple backends, some sw and some hw.
> User will be able to specify which backed he wants to use for particular
> "commands".
> 
> So for example, ovs kernel datapath module will implement an xflows
> backend and register it as "ovsdp". Rocker will implement another xflows
> backend and register it as "rockerdp". Then, ovs userspace will use xflows
> api to setup both backends independently, but using the same xflows api.
> 
> It is still up to userspace to decide what should be put where (what
> backend to use).

OK, sounds good so far. Although we can't completely ditch the existing
genl based OVS flow API for obvious backwards compatibility reasons ;-)

How does John's API fit into this? How would you expose capabilities
through xflows? How would it differ from what John proposes?

Since this would be a regular tc classifier I assume it could be
attached to any tc class and interface and then combined with other
classifiers which OVS would not be aware of. How do you intend to
resolve such conflicts?

Example:
 eth0:
   ingress qdisc:
     cls prio 20 u32 match [...]
     cls prio 10 xflows [...]

If xflows offloads to hardware, the u32 classifier with higher
priority is hidden unintentionally.
