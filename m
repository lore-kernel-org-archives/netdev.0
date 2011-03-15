From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/4] netfilter: xt_connlimit: fix daddr connlimit in SNAT
 scenario
Date: Tue, 15 Mar 2011 13:21:53 +0100
Message-ID: <4D7F59E1.5060506@trash.net>
References: <1300085414-27275-1-git-send-email-xiaosuo@gmail.com> <alpine.LNX.2.01.1103141310140.27542@obet.zrqbmnf.qr> <AANLkTi=QgVBVAPcTmb_La=VJOLq5LmGPqMfw7bbCuByP@mail.gmail.com> <alpine.LNX.2.01.1103141955180.21929@obet.zrqbmnf.qr> <AANLkTimBV9x7Y-tUez5VMDoU+8mtaw1f48GV1yxgZ71c@mail.gmail.com> <alpine.LNX.2.01.1103150210370.21929@obet.zrqbmnf.qr> <AANLkTinZiVbVttzNuGdShC25=BtwJUzhSX_YZBxAr+qF@mail.gmail.com> <alpine.LNX.2.01.1103150302310.27019@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Changli Gao <xiaosuo@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.01.1103150302310.27019@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 15.03.2011 03:05, Jan Engelhardt wrote:
> On Tuesday 2011-03-15 02:30, Changli Gao wrote:
> 
>> On Tue, Mar 15, 2011 at 9:16 AM, Jan Engelhardt <jengelh@medozas.de> wrote:
>>>
>>>
>>> The original tuple may not be updated, but the reply tuple is.
>>> And we are taking the reply tuple in
>>>
>>>        tuple_ptr = &ct->tuplehash[IP_CT_DIR_REPLY].tuple;
>>>
>>> which is subsequently copied to conn->tuple on the first invocation.
>>>
>>> Afterwards, SNAT will update ct->tuplehash[reply].tuple, and so
>>> conn->tuple is outdated. Calling nf_conntrack_find_get(conn->tuple)
>>> in count_them would then fail, would it not?
>>>
>>
>> After my patch, tuple is only used to look up the corresponding
>> conntrack.
> 
> Ok, the patch may be applied. Somehow I was under the impression
> addr was extracted from tuple_ptr, but it is, in fact, not.
> 

OK, thanks, I'll apply patches 1-4.
