From: Vlastimil Babka <vbabka@suse.cz>
Subject: Re: [PATCH percpu/for-4.7-fixes 2/2] percpu: fix synchronization
 between synchronous map extension and chunk destruction
Date: Thu, 26 May 2016 11:48:41 +0200
Message-ID: <0613d173-2ff1-a904-9611-0c6fc254f45e@suse.cz>
References: <5713C0AD.3020102@oracle.com>
 <20160417172943.GA83672@ast-mbp.thefacebook.com> <5742F127.6080000@suse.cz>
 <5742F267.3000309@suse.cz> <20160523213501.GA5383@mtj.duckdns.org>
 <57441396.2050607@suse.cz> <20160524153029.GA3354@mtj.duckdns.org>
 <20160524190433.GC3354@mtj.duckdns.org>
 <CAADnVQ+GprFZJkvCKHVN1gmBMO6uORimsNZ4tE-jgPPOcZhCfA@mail.gmail.com>
 <20160525154525.GF3354@mtj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sasha Levin <sasha.levin@oracle.com>, Alexei Starovoitov
 <ast@kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>,
 Linux-MM layout <linux-mm@kvack.org>, Marco Grassi <marco.gra@gmail.com>,
 kernel-team@fb.com
To: Tejun Heo <tj@kernel.org>,
 Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20160525154525.GF3354@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On 05/25/2016 05:45 PM, Tejun Heo wrote:
> For non-atomic allocations, pcpu_alloc() can try to extend the area
> map synchronously after dropping pcpu_lock; however, the extension
> wasn't synchronized against chunk destruction and the chunk might get
> freed while extension is in progress.
>
> This patch fixes the bug by putting most of non-atomic allocations
> under pcpu_alloc_mutex to synchronize against pcpu_balance_work which
> is responsible for async chunk management including destruction.
>
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Reported-and-tested-by: Alexei Starovoitov <alexei.starovoitov@gmail.com>
> Reported-by: Vlastimil Babka <vbabka@suse.cz>
> Reported-by: Sasha Levin <sasha.levin@oracle.com>
> Cc: stable@vger.kernel.org # v3.18+
> Fixes: 1a4d76076cda ("percpu: implement asynchronous chunk population")

Didn't spot any problems this time.

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
