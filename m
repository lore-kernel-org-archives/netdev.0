From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] net: don't call strlen on non-terminated string in
 dev_set_alias()
Date: Tue, 06 Jun 2017 21:04:27 -0400 (EDT)
Message-ID: <20170606.210427.2001413617170270195.davem@davemloft.net>
References: <20170606135654.111884-1-glider@google.com>
        <20170606.163639.1246601020260541080.davem@davemloft.net>
        <20170606215735.GA18283@breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: glider@google.com, dvyukov@google.com, kcc@google.com,
        edumazet@google.com, stephen@networkplumber.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170606215735.GA18283@breakpoint.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>
Date: Tue, 6 Jun 2017 23:57:35 +0200

> David Miller <davem@davemloft.net> wrote:
>> From: Alexander Potapenko <glider@google.com>
>> Date: Tue,  6 Jun 2017 15:56:54 +0200
>> 
>> > KMSAN reported a use of uninitialized memory in dev_set_alias(),
>> > which was caused by calling strlcpy() (which in turn called strlen())
>> > on the user-supplied non-terminated string.
>> > 
>> > Signed-off-by: Alexander Potapenko <glider@google.com>
>> 
>> We should not be allowing non-NULL terminated strings for the
>> IFLA_IFALIAS attribute.  It's defined as type NLA_STRING in
>> the ifla_policy[] array.
> 
> Unfortunately NLA_STRING doesn't check for NUL byte, only
> NLA_NUL_STRING does this.
> 
> So unless you think we can change kernel and make NLA_STRING
> behave like NLA_NUL_STRING I think patch is correct.

Ok, I missed that, thanks for the clarification.

I'll apply this and queue it up for -stable, thanks.
