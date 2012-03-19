From: Christoph Lameter <cl@linux.com>
Subject: Re: netfilter: Hung task
Date: Mon, 19 Mar 2012 15:03:14 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1203191501140.23632@router.home>
References: <CA+1xoqfCTXxXsbfUjttuOVutyD_FzYS8PoOoAOOtB72P8SwdVg@mail.gmail.com> <20120318141943.GA28850@1984> <CA+1xoqcQYqCgQb=1M5PVkm=6SBhV2oJxJ2CtBp=gAvZM36Kc2Q@mail.gmail.com> <20120319002811.GA30408@1984> <alpine.DEB.2.00.1203190854560.16879@router.home>
 <CA+1xoqdo5zvUe+=BYr42iEEq9mU=kd1zVxrGhQc0sNYqbpBkNQ@mail.gmail.com> <alpine.DEB.2.00.1203191129440.20196@router.home> <CA+1xoqeinbEVMUGu=zx8nDbdDFx30RiTS=qiSgFKZnSYYPDZ+Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, kaber@trash.net,
	davem@davemloft.net, Dave Jones <davej@redhat.com>,
	netfilter-devel@vger.kernel.org,
	"linux-kernel@vger.kernel.org List" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Sasha Levin <levinsasha928@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <CA+1xoqeinbEVMUGu=zx8nDbdDFx30RiTS=qiSgFKZnSYYPDZ+Q@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 19 Mar 2012, Sasha Levin wrote:

> lockdep listed all the held locks there.

None of the locks listed are slub locks.

> I've mentioned that it looks very similar to
> https://lkml.org/lkml/2012/1/14/45 where the userspace helper tried to
> read from the sysfs files, but got into a deadlock since the kernel
> side held them before it called the usermode helper.

Ah yes. In that case slub held a semaphore. Code was changed since then to
no longer hold a semaphore when calling into sysfs.

The uevent handler can execute arbitrary user space code. Do you have to
hold locks while calling kmem_cache_destroy?


