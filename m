From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 0/14] prism54: bring up to sync with prism54.org cvs rep
Date: Thu, 27 May 2004 14:39:24 -0400
Sender: prism54-devel-admin@prism54.org
Message-ID: <40B635DC.4070708@pobox.com>
References: <20040524083003.GA3330@ruslug.rutgers.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
	netdev@oss.sgi.com, prism54-devel@prism54.org
Return-path: <prism54-devel-admin@prism54.org>
To: "Luis R. Rodriguez" <mcgrof@ruslug.rutgers.edu>
In-Reply-To: <20040524083003.GA3330@ruslug.rutgers.edu>
Errors-To: prism54-devel-admin@prism54.org
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Post: <mailto:prism54-devel@prism54.org>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel/>
List-Id: netdev.vger.kernel.org

Luis R. Rodriguez wrote:
> Jeff,
> 
> Please apply the following patches to linux-2.6.7-rc1. These patches
> bring the kernel tree up to sync with prism54.org's 1.2's release.
> 
> [PATCH 1/14 linux-2.6.7-rc1] prism54: add new private ioctls

Change OK once cleanups are moved to separate patch.


> [PATCH 2/14 linux-2.6.7-rc1] prism54: reset card on tx_timeout

OK


> [PATCH 3/14 linux-2.6.7-rc1] prism54: add iwspy support

Change OK, patch rejected due to Lindent (!!!) being included in this 
patch as well as functional changes.


> [PATCH 4/14 linux-2.6.7-rc1] prism54: add support for avs header in monitor mode

OK


> [PATCH 5/14 linux-2.6.7-rc1] prism54: new prism54 kernel compatibility

rejected, see Arjan's comments

also, prismcompat24.h doesn't belong in the 2.6 kernel.


> [PATCH 6/14 linux-2.6.7-rc1] prism54: Fix prism54.org bugs 74, 75

OK


> [PATCH 7/14 linux-2.6.7-rc1] prism54: Fix 2.4 build

rejected, as per comment for patch #5


> [PATCH 8/14 linux-2.6.7-rc1] prism54: Fix prism54.org bugs 39, 73

cleanups and bug fixes mixed together in same patch.

Change OK once cleanups are moved to separate patch.


> [PATCH 9/14 linux-2.6.7-rc1] prism54: Fix prism54.org bug 77; strengthened oid transaction

More functional changes mixed in with whitespace and formatting cleanups.

Change OK once cleanups are moved to separate patch.


> [PATCH 10/14 linux-2.6.7-rc1] prism54: Don't allow mib reads while unconfigured

Change OK once cleanups are moved to separate patch.


> [PATCH 11/14 linux-2.6.7-rc1] prism54: Touched up kernel compatibility

Rejected due to patch #5 comments.


> [PATCH 12/14 linux-2.6.7-rc1] prism54: Start using likely/unlikely

Use of likely()/unlikely() is OK.

A change to skb_reserve() was snuck into this patch, completely 
unrelated to $subject.  Also, meaningless cleanups obscure things here too.


> [PATCH 13/14 linux-2.6.7-rc1] prism54: Fix 2.4 SMP build

I agree with this change, but this patch also includes unrelated changes!!


> [PATCH 14/14 linux-2.6.7-rc1] prism54: Fix channel stats; bump to 1.2

OK


Summary:  I'm glad you broke up the changes into multiple patches. 
Thank you.  However, the patches were separated in non-sensical ways. 
Follow these guidelines:

1) With this many patches, cosmetic changes (whitespace, formatting, 
Lindent) should be in separate patches from functional changes.

2) Fully describe all the changes in the patch.  If a patch says "fix 
2.4 SMP build", it should do that and nothing else.

3) Kernel compatibility is achieved by coding for the latest kernel 
(2.6.x), and then creating back-compat definitions that make the 2.6.x 
API (as it's used in your driver) work under earlier kernels.  This is 
known as the "kcompat" approach.  See the kcompat toolkit at 
http://sf.net/projects/gkernel/ for examples.

Please resend the patch series with the changes requested.  It is OK if 
you lump Lindent/whitespace/formatting changes into one big patch, if 
you wish -- assuming that patch contains nothing else.

	Jeff
