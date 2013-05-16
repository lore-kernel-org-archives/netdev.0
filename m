From: Asias He <asias@redhat.com>
Subject: Re: [PATCH] vhost-scsi: Depend on NET for memcpy_fromiovec
Date: Thu, 16 May 2013 10:08:48 +0800
Message-ID: <20130516020848.GB23441@hj.localdomain>
References: <20130515095558.918f2b29ba318a477eb5dde2@canb.auug.org.au>
	<1368579583-13097-1-git-send-email-asias@redhat.com>
	<8761yk254u.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, kvm@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	Randy Dunlap <rdunlap@infradead.org>, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	target-devel@vger.kernel.org, linux-next@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <8761yk254u.fsf@rustcorp.com.au>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Wed, May 15, 2013 at 02:47:53PM +0930, Rusty Russell wrote:
> Asias He <asias@redhat.com> writes:
> > scsi.c includes vhost.c which uses memcpy_fromiovec.
> >
> > This patch fixes this build failure.
> >
> >    From Randy Dunlap:
> >    '''
> >    on x86_64:
> >
> >    ERROR: "memcpy_fromiovec" [drivers/vhost/vhost_scsi.ko] undefined!
> >
> >    It needs to depend on NET since net/core/ provides that function.
> >    '''
> 
> Proper fix please.

--verbose please ;-)

Making VHOST_SCSI depends on NET looks weird but this is because vhost
core depends on it. A bunch of patches are cleaning this up. Since MST
wanted do the vhost.ko split up in 3.11, plus your WIP vringh work, so I
wanted the fix for 3.10 as minimum as possible.

Other users are using memcpy_fromiovec and friends outside net. It seems
a good idea to put it in a util library. e.g.  crypto/algif_skcipher.c
which also depends on NET for it.

> Though I can't see why you thought this was a good idea.  Nonetheless, I
> shan't highlight why: I have far too much respect for your intellects
> and abilities.
> 
> No, don't thank me!

Interesting.

> Rusty.

-- 
Asias
