From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC PATCH 00/30] Kernel NET policy
Date: Mon, 18 Jul 2016 22:51:05 +0200
Message-ID: <578D4139.7060201@iogearbox.net>
References: <1468824984-65318-1-git-send-email-kan.liang@intel.com> <578D0244.7010707@iogearbox.net> <37D7C6CF3E00A74B8858931C1DB2F07712C197F1@SHSMSX103.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"mingo@redhat.com" <mingo@redhat.com>,
	"peterz@infradead.org" <peterz@infradead.org>,
	"kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"keescook@chromium.org" <keescook@chromium.org>,
	"viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>,
	"gorcunov@openvz.org" <gorcunov@openvz.org>,
	"john.stultz@linaro.org" <john.stultz@linaro.org>,
	"aduyck@mirantis.com" <aduyck@mirantis.com>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	"decot@googlers.com" <decot@googlers.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"andi@firstfloor.org" <andi@firstfloor.org>,
	"tj@kernel.org" <tj@kernel.org>
To: "Liang, Kan" <kan.liang@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:47643 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751630AbcGRUvS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 16:51:18 -0400
In-Reply-To: <37D7C6CF3E00A74B8858931C1DB2F07712C197F1@SHSMSX103.ccr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/18/2016 08:30 PM, Liang, Kan wrote:
>> On 07/18/2016 08:55 AM, kan.liang@intel.com wrote:
[...]
>> On a higher level picture, why for example, a new cgroup in combination
>> with tc shouldn't be the ones resolving these policies on resource usage?
>
> The NET policy doesn't support cgroup yet, but it's on my todo list.
> The granularity for the device resource is per queue. The packet will be
> redirected to the specific queue.
> I'm not sure if cgroup with tc can do that.

Did you have a look at sch_mqprio, which can be used along with either
netprio cgroup or netcls cgroup plus tc on clsact's egress side to set
the priority for mqprio mappings from application side? At leats ixgbe,
i40e, fm10k have offload support for it and a number of other nics. You
could also use cls_bpf for making the prio assignment if you need to
involve also other meta data from the skb (like mark or prio derived from
sockets, etc). Maybe it doesn't cover all of what you need, but could be
a start to extend upon?

Thanks,
Daniel
