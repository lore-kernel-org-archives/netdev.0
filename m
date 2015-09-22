From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH v2] lib: fix data race in rhashtable_rehash_one
Date: Tue, 22 Sep 2015 11:17:38 +0200
Message-ID: <20150922091738.GD13047@pox.localdomain>
References: <1442911912-66882-1-git-send-email-dvyukov@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kcc@google.com,
	andreyknvl@google.com, glider@google.com, ktsan@googlegroups.com,
	paulmck@linux.vnet.ibm.com
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1442911912-66882-1-git-send-email-dvyukov@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/22/15 at 10:51am, Dmitry Vyukov wrote:
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

Acked-by: Thomas Graf <tgraf@suug.ch>
