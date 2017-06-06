From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] net: don't call strlen on non-terminated string in
 dev_set_alias()
Date: Tue, 06 Jun 2017 16:36:39 -0400 (EDT)
Message-ID: <20170606.163639.1246601020260541080.davem@davemloft.net>
References: <20170606135654.111884-1-glider@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dvyukov@google.com, kcc@google.com, edumazet@google.com,
        stephen@networkplumber.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: glider@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170606135654.111884-1-glider@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexander Potapenko <glider@google.com>
Date: Tue,  6 Jun 2017 15:56:54 +0200

> KMSAN reported a use of uninitialized memory in dev_set_alias(),
> which was caused by calling strlcpy() (which in turn called strlen())
> on the user-supplied non-terminated string.
> 
> Signed-off-by: Alexander Potapenko <glider@google.com>

We should not be allowing non-NULL terminated strings for the
IFLA_IFALIAS attribute.  It's defined as type NLA_STRING in
the ifla_policy[] array.

Please figure out why we aren't enforcing the attribute policy
properly, rather than adding a workaround.

Thanks.
