From: Richard Weinberger <richard@nod.at>
Subject: Re: nf_conntrack: Infoleak via CTA_ID and CTA_EXPECT_ID
Date: Wed, 12 Jul 2017 23:26:35 +0200
Message-ID: <1daf1401-5009-df1c-a77a-a271811c0760@nod.at>
References: <c84e0301-2bb6-8932-2ed5-939340762159@nod.at>
 <20170630193544.GM9307@breakpoint.cc>
 <f3d78dc5-7694-8e01-ac4d-54fc248a96f1@nod.at>
 <20170630195547.GN9307@breakpoint.cc>
 <ad87cf0f-2ff4-48d7-b53c-bc4b5e98cfca@nod.at>
 <20170701103504.GO9307@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        David Miller <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        David Gstir <david@sigma-star.at>, kaber@trash.net,
        "keescook@chromium.org" <keescook@chromium.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170701103504.GO9307@breakpoint.cc>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Florian,

Am 01.07.2017 um 12:35 schrieb Florian Westphal:
>>> Perhaps we can place that in a new extension (its not needed in any
>>> fastpath ops)?
>>
>> To get rid of the infoleak we have to re-introduce the id field in struct nf_conn
>> and struct nf_conntrack_expect.
> 
> Why will this not work?

You are right, when we compute the ID from the whole object, it should be fine.

>> Otherwise have nothing to compare against in the conntrack/expect remove case.
> 
> Not following, sorry.  The id is not used anywhere except when we send
> info to userspace.
> 
> The compare on removal is not needed afaics, and its also not used when
> doing lookup to begin with, so we can just recompute it?

Isn't this a way too much overhead?

I personally favor Pablo's per-cpu counter approach.
That way the IDs are unique again and we get rid of the info leak without
much effort.

Thanks,
//richard
