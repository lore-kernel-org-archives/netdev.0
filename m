From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH net-next 1/3] net: Add function for parsing the header
 length out of linear ethernet frames
Date: Fri, 05 Sep 2014 16:15:10 -0700
Message-ID: <540A43FE.7050708@intel.com>
References: <20140905180642.730.22292.stgit@ahduyck-bv4.jf.intel.com>	<20140905180951.730.86041.stgit@ahduyck-bv4.jf.intel.com> <CAADnVQKNoOdSuuQ-voKVNpke-4BjvC_pU=g65=m70Y4TsTpTag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	jeffrey.t.kirsher@intel.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:30025 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752069AbaIEXPL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Sep 2014 19:15:11 -0400
In-Reply-To: <CAADnVQKNoOdSuuQ-voKVNpke-4BjvC_pU=g65=m70Y4TsTpTag@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/05/2014 01:02 PM, Alexei Starovoitov wrote:
> On Fri, Sep 5, 2014 at 11:10 AM, Alexander Duyck
> <alexander.h.duyck@intel.com> wrote:
>> This patch updates some of the flow_dissector api so that it can be used to
>> parse the length of ethernet buffers stored in fragments.  Most of the
>> changes needed were to __skb_get_poff as it needed to be updated to support
>> sending a linear buffer instead of a skb.
>>
>>
>>  u32 __skb_get_poff(const struct sk_buff *skb);
>> +u32 ___skb_get_poff(const struct sk_buff *skb, void *data,
>> +                   const struct flow_keys *keys, int hlen);
> 
> three underscores and not a static function?
> May be we need to come with a proper name for it.
> Two easy to confuse with two underscore version...

Actually what I could do is probably rename the 2 underscore version to
drop the underscores and then rename the 3 underscore version to just 2
underscores.  Then it would match up closer with how the other functions
are dealing with the data/hlen values.

Thanks,

Alex
