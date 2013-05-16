From: Asias He <asias@redhat.com>
Subject: Re: [PATCH] vhost-scsi: Depend on NET for memcpy_fromiovec
Date: Thu, 16 May 2013 10:16:36 +0800
Message-ID: <20130516021636.GA24175@hj.localdomain>
References: <20130515095558.918f2b29ba318a477eb5dde2@canb.auug.org.au>
	<1368579583-13097-1-git-send-email-asias@redhat.com>
	<8761yk254u.fsf@rustcorp.com.au>
	<1368657450.6899.29.camel@haakon3.risingtidesystems.com>
	<871u9724vp.fsf@rustcorp.com.au>
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
In-Reply-To: <871u9724vp.fsf@rustcorp.com.au>
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

On Thu, May 16, 2013 at 09:05:38AM +0930, Rusty Russell wrote:
> "Nicholas A. Bellinger" <nab@linux-iscsi.org> writes:
> > On Wed, 2013-05-15 at 14:47 +0930, Rusty Russell wrote:
> >> Asias He <asias@redhat.com> writes:
> >> > scsi.c includes vhost.c which uses memcpy_fromiovec.
> >> >
> >> > This patch fixes this build failure.
> >> >
> >> >    From Randy Dunlap:
> >> >    '''
> >> >    on x86_64:
> >> >
> >> >    ERROR: "memcpy_fromiovec" [drivers/vhost/vhost_scsi.ko] undefined!
> >> >
> >> >    It needs to depend on NET since net/core/ provides that function.
> >> >    '''
> >> 
> >> Proper fix please.
> >> 
> >> Though I can't see why you thought this was a good idea.  Nonetheless, I
> >> shan't highlight why: I have far too much respect for your intellects
> >> and abilities.
> >> 
> >> No, don't thank me!
> >
> > Hi Rusty & Asias,
> >
> > I assume you mean something like the following patch to allow kbuild to
> > work when VHOST_NET + VHOST_SCSI are both enabled and sharing vhost.o,
> > yes..?
> 
> No, that's a separate issue.
> 
> memcpy_fromiovec() has nothing to do with networking: that was just the
> first user.  Note that crypto/algif_skcipher.c also uses it.  The
> obvious answer is to move it into lib/.

That's true. I also want this.

> OTOH making vhost_scsi depend on CONFIG_NET is breathtakingly lazy.  I
> expect better from experienced kernel hackers :(

But do you think moving the memcpy_fromiovec stuff is a 3.10 material?

> Rusty.

-- 
Asias
