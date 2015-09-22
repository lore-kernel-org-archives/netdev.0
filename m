From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] lib: fix data race in rhashtable_rehash_one
Date: Tue, 22 Sep 2015 02:05:10 -0700
Message-ID: <1442912710.29850.75.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1442911912-66882-1-git-send-email-dvyukov@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tgraf@suug.ch, kcc@google.com, andreyknvl@google.com,
	glider@google.com, ktsan@googlegroups.com,
	paulmck@linux.vnet.ibm.com
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1442911912-66882-1-git-send-email-dvyukov@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-09-22 at 10:51 +0200, Dmitry Vyukov wrote:
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
> ---

Thanks Dmitry

Acked-by: Eric Dumazet <edumazet@google.com>
