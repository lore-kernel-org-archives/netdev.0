From: Christoph Lameter <cl@linux.com>
Subject: Re: netfilter: active obj WARN when cleaning up
Date: Mon, 2 Dec 2013 19:00:23 +0000
Message-ID: <00000142b4aeca89-186fc179-92b8-492f-956c-38a7c196d187-000000@email.amazonses.com>
References: <alpine.DEB.2.02.1311271106090.30673@ionos.tec.linutronix.de> <20131127113939.GL16735@n2100.arm.linux.org.uk> <alpine.DEB.2.02.1311271409280.30673@ionos.tec.linutronix.de> <20131127133231.GO16735@n2100.arm.linux.org.uk> <20131127134015.GA6011@n2100.arm.linux.org.uk>
 <alpine.DEB.2.02.1311271443580.30673@ionos.tec.linutronix.de> <20131127233415.GB19270@kroah.com> <00000142b4282aaf-913f5e4c-314c-4351-9d24-615e66928157-000000@email.amazonses.com> <20131202164039.GA19937@kroah.com>
 <00000142b4514eb5-2e8f675d-0ecc-423b-9906-58c5f383089b-000000@email.amazonses.com> <20131202172615.GA4722@kroah.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Thomas Gleixner <tglx@linutronix.de>,
    Russell King - ARM Linux <linux@arm.linux.org.uk>,
    Pablo Neira Ayuso <pablo@netfilter.org>,
    Sasha Levin <sasha.levin@oracle.com>, Patrick McHardy <kaber@trash.net>,
    kadlec@blackhole.kfki.hu, "David S. Miller" <davem@davemloft.net>,
    netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
    netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
    linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
To: Greg KH <greg@kroah.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20131202172615.GA4722@kroah.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Mon, 2 Dec 2013, Greg KH wrote:

> >
> > We need our own reference count. So we just have to defer the
> > release of the kmem_cache struct until the ->release callback is
> > triggered. The put of the embedded kobject must be the last action on the
> > kmem_cache  structure which will then trigger release and that will
> > trigger the kmem_cache_free().
> >
>
> Ok, that sounds reasonable, or you can just create a "tiny" structure
> for the kobject that has a pointer back to your kmem_cache structure
> that you can then reference from the show/store functions.  Either is
> fine with me.

Problem is that the release field is only available if
CONFIG_DEBUG_KOBJECT_RELEASE is enabled. Without the callback I cannot
tell when it is legit to release the kobject structure unless I keep
scanning it once in awhile.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
