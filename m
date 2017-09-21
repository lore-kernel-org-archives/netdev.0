From: Kees Cook <keescook@chromium.org>
Subject: Re: [kernel-hardening] Re: [PATCH v3 03/31] usercopy: Mark kmalloc
 caches as usercopy caches
Date: Thu, 21 Sep 2017 08:40:00 -0700
Message-ID: <CAGXu5j+X6dWCGocG=P7pszTY-5OZ6Jmp-RsnDKox75M5rmVe4g@mail.gmail.com>
References: <1505940337-79069-1-git-send-email-keescook@chromium.org>
 <1505940337-79069-4-git-send-email-keescook@chromium.org> <alpine.DEB.2.20.1709211024120.14427@nuc-kabylake>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: LKML <linux-kernel@vger.kernel.org>, David Windsor <dave@nullcore.net>,
	Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>,
	Linux-MM <linux-mm@kvack.org>, linux-xfs@vger.kernel.org,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>
To: Christopher Lameter <cl@linux.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <alpine.DEB.2.20.1709211024120.14427@nuc-kabylake>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 21, 2017 at 8:27 AM, Christopher Lameter <cl@linux.com> wrote:
> On Wed, 20 Sep 2017, Kees Cook wrote:
>
>> --- a/mm/slab.c
>> +++ b/mm/slab.c
>> @@ -1291,7 +1291,8 @@ void __init kmem_cache_init(void)
>>        */
>>       kmalloc_caches[INDEX_NODE] = create_kmalloc_cache(
>>                               kmalloc_info[INDEX_NODE].name,
>> -                             kmalloc_size(INDEX_NODE), ARCH_KMALLOC_FLAGS);
>> +                             kmalloc_size(INDEX_NODE), ARCH_KMALLOC_FLAGS,
>> +                             0, kmalloc_size(INDEX_NODE));
>>       slab_state = PARTIAL_NODE;
>>       setup_kmalloc_cache_index_table();
>
> Ok this presumes that at some point we will be able to restrict the number
> of bytes writeable and thus set the offset and size field to different
> values. Is that realistic?
>
> We already whitelist all kmalloc caches (see first patch).
>
> So what is the point of this patch?

The DMA kmalloc caches are not whitelisted:

>>                         kmalloc_dma_caches[i] = create_kmalloc_cache(n,
>> -                               size, SLAB_CACHE_DMA | flags);
>> +                               size, SLAB_CACHE_DMA | flags, 0, 0);

So this is creating the distinction between the kmallocs that go to
userspace and those that don't. The expectation is that future work
can start to distinguish between "for userspace" and "only kernel"
kmalloc allocations, as is already done here for DMA.

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
