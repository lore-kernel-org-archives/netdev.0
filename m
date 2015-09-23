From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] lib: fix data race in rhashtable_rehash_one
Date: Tue, 22 Sep 2015 17:36:29 -0700 (PDT)
Message-ID: <20150922.173629.1910444040173069955.davem@davemloft.net>
References: <1442911912-66882-1-git-send-email-dvyukov@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, tgraf@suug.ch, kcc@google.com,
	andreyknvl@google.com, glider@google.com, ktsan@googlegroups.com,
	paulmck@linux.vnet.ibm.com
To: dvyukov@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1442911912-66882-1-git-send-email-dvyukov@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 22 Sep 2015 10:51:52 +0200

> rhashtable_rehash_one() uses complex logic to update entry->next field,
> after INIT_RHT_NULLS_HEAD and NULLS_MARKER expansion:
> 
> entry->next = 1 | ((base + off) << 1)
> 
> This can be compiled along the lines of:
> 
> entry->next = base + off
> entry->next <<= 1
> entry->next |= 1
> 
> Which will break concurrent readers.
> 
> NULLS value recomputation is not needed here, so just remove
> the complex logic.
> 
> The data race was found with KernelThreadSanitizer (KTSAN).
> 
> Signed-off-by: Dmitry Vyukov <dvyukov@google.com>

Applied, thanks.
