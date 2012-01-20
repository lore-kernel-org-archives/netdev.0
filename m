From: Christoph Lameter <cl@linux.com>
Subject: Re: Hung task when calling clone() due to netfilter/slab
Date: Thu, 19 Jan 2012 20:03:51 -0600 (CST)
Message-ID: <alpine.DEB.2.00.1201191959540.14480@router.home>
References: <1326558605.19951.7.camel@lappy> <1326561043.5287.24.camel@edumazet-laptop> <1326632384.11711.3.camel@lappy> <1326648305.5287.78.camel@edumazet-laptop> <alpine.DEB.2.00.1201170910130.4800@router.home> <1326813630.2259.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <alpine.DEB.2.00.1201170927020.4800@router.home> <1326814208.2259.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <alpine.DEB.2.00.1201170942240.4800@router.home> <alpine.DEB.2.00.1201171620590.14697@router.home> <m1bopz2ws3.fsf@fess.ebiederm.org>
 <m14nvr2vbu.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
  Sasha Levin <levinsasha928@gmail.com>, Dave Jones <davej@redhat.com>,
  davem <davem@davemloft.net>, Pekka Enberg <penberg@kernel.org>,
  Matt Mackall <mpm@selenic.com>, kaber@trash.net, pablo@netfilter.org,
  linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
  netfilter-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <m14nvr2vbu.fsf@fess.ebiederm.org>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Thu, 19 Jan 2012, Eric W. Biederman wrote:

> Oh.  I see.  The problem is calling kobject_uevent (which happens to
> live in slabs sysfs_slab_add) with a lock held.  And kobject_uevent
> makes a blocking call to userspace.
>
> No locks held seems to be a good policy on that one.

Well we can just remove that call to kobject_uevent instead then. Does it
do anything useful? Cannot remember why we put that in there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
