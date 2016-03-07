From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: 4.4.3: OOPS when running "stress-ng --sock 5"
Date: Mon, 7 Mar 2016 19:59:38 +0900
Message-ID: <201603071959.DEB60919.tOFFVOMLSHOQJF@I-love.SAKURA.ne.jp>
References: <87twkmd6or.fsf@gmail.com>
	<87povack3q.fsf@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org
To: holgerschurig@gmail.com
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <87povack3q.fsf@gmail.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Holger Schurig wrote:
> So I did an "arm-linux-gnueabihf-objdump -Sgd linux/vmlinux", not sure
> if that helps:
> 
> c00972ec <__rmqueue>:
>  * Do the hard work of removing an element from the buddy allocator.
>  * Call me with the zone->lock already held.
>  */
> static struct page *__rmqueue(struct zone *zone, unsigned int order,
>                                 int migratetype, gfp_t gfp_flags)
> {
> c00972ec:       e1a0c00d        mov     ip, sp
> c00972f0:       e92ddff0        push    {r4, r5, r6, r7, r8, r9, sl, fp, ip, lr, pc}
> c00972f4:       e24cb004        sub     fp, ip, #4
> c00972f8:       e24dd024        sub     sp, sp, #36     ; 0x24
>         unsigned int current_order;
>         struct free_area *area;
>         struct page *page;
> 
>         /* Find a page of the appropriate size in the preferred list */
>         for (current_order = order; current_order < MAX_ORDER; ++current_order) {
> c00972fc:       e351000a        cmp     r1, #10
>  * Do the hard work of removing an element from the buddy allocator.
>  * Call me with the zone->lock already held.
>  */
> 
I tried on x86_64 but I could not reproduce it.
Thus, we need to examine this problem using your environment.

I didn't notice that c00972ec is __rmqueue+0x0.
Actual line number to examine is c0097360 ("pc" register) which is __rmqueue+0x74.
Please show us line number and assembly code around c0097360.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
