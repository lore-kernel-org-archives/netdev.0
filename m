From: Richard Weinberger <richard@nod.at>
Subject: Re: nf_conntrack: Infoleak via CTA_ID and CTA_EXPECT_ID
Date: Fri, 30 Jun 2017 22:23:24 +0200
Message-ID: <ad87cf0f-2ff4-48d7-b53c-bc4b5e98cfca@nod.at>
References: <c84e0301-2bb6-8932-2ed5-939340762159@nod.at>
 <20170630193544.GM9307@breakpoint.cc>
 <f3d78dc5-7694-8e01-ac4d-54fc248a96f1@nod.at>
 <20170630195547.GN9307@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        David Miller <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        David Gstir <david@sigma-star.at>, kaber@trash.net,
        "keescook@chromium.org" <keescook@chromium.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170630195547.GN9307@breakpoint.cc>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Florian,

Am 30.06.2017 um 21:55 schrieb Florian Westphal:
>>> Why not use a hash of the address?
>>
>> Would also work. Or xor it with a random number.
>>
>> On the other hand, for user space it would be more useful when the conntrack id
>> does not repeat that often. That's why I favor the good old counter method.
>> Currently the conntrack id is reused very fast.
>> e.g. in one of our applications we use the conntack id via NFQUEUE and watch the
>> destroy events via conntrack. It happens regularly that a new connection has the
>> same id than a different connection we saw some moments before, before we receive
>> the destroy event from the conntrack socket.
> 
> Perhaps we can place that in a new extension (its not needed in any
> fastpath ops)?

To get rid of the infoleak we have to re-introduce the id field in struct nf_conn
and struct nf_conntrack_expect.
Otherwise have nothing to compare against in the conntrack/expect remove case.

So the only question is what to store, IMHO a counter that can wrap around is the
cheapest method and would also not harm the fast-path.

Thanks,
//richard
