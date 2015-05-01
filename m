From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH net-next] net: sched: run ingress qdisc without locks
Date: Fri, 01 May 2015 07:04:43 -0700
Message-ID: <554387FB.5040008@intel.com>
References: <1430450047-5671-1-git-send-email-ast@plumgrid.com> <55436CB2.9070506@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:12965 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753783AbbEAOE6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 May 2015 10:04:58 -0400
In-Reply-To: <55436CB2.9070506@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/01/2015 05:08 AM, Jamal Hadi Salim wrote:
> On 04/30/15 23:14, Alexei Starovoitov wrote:
>> TC classifiers/actions were converted to RCU by John in the series:
>> http://thread.gmane.org/gmane.linux.network/329739/focus=329739
>> and many follow on patches.
>> This is the last patch from that series that finally drops
>> ingress spin_lock.
>>
> 
> As the culprit who added this lock I would like to offer a kudos
> to John for the hard work. Alexei thanks for the hard work in
> pursuing this further.
> And to the rest of the community who has been beating up on me
> all these years, you can stop now ;->

Well there is still the TX side, although not as obvious because
of mq and mqprio. Hopefully by say next LPC we can remove the
qdisc lock there in many scenarios. Also the netif_tx_lock is
there as well but many (most?) of the 10G/40G/etc devices can
create per core descriptor rings. I'll start prodding away on that
side shortly I suppose.

> 
> I think this at least deserves a:
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
> 
> cheers,
> jamal
