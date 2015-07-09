From: Thomas Huth <thuth@redhat.com>
Subject: Re: [PATCH] KVM: Add Kconfig option to signal cross-endian guests
Date: Thu, 9 Jul 2015 20:59:26 +0200
Message-ID: <20150709205926.1f00b6b2@thh440s>
References: <20150707195012-mutt-send-email-mst@redhat.com>
	<1436428145-29823-1-git-send-email-thuth@redhat.com>
	<559E435E.9050608@redhat.com> <559E6FBD.5050502@redhat.com>
	<20150709160626-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Laurent Vivier <lvivier@redhat.com>, kvm@vger.kernel.org,
	Gleb Natapov <gleb@kernel.org>, linux-kernel@vger.kernel.org,
	kvm-ppc@vger.kernel.org, virtualization@lists.linux-foundation.org,
	Marc Zyngier <marc.zyngier@arm.com>, Paul Mackerras <paulus@samba.org>,
	Christoffer Dall <christoffer.dall@linaro.org>,
	netdev@vger.kernel.org, Paolo Bonzini <pbonzini@redhat.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20150709160626-mutt-send-email-mst@redhat.com>
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

On Thu, 9 Jul 2015 16:07:47 +0300
"Michael S. Tsirkin" <mst@redhat.com> wrote:

> On Thu, Jul 09, 2015 at 02:57:33PM +0200, Paolo Bonzini wrote:
> > 
> > 
> > On 09/07/2015 11:48, Laurent Vivier wrote:
> > > 
> > > 
> > > On 09/07/2015 09:49, Thomas Huth wrote:
> > >> The option for supporting cross-endianness legacy guests in
> > >> the vhost and tun code should only be available on systems
> > >> that support cross-endian guests.
> > > 
> > > I'm sure I misunderstand something, but what happens if we use QEMU with
> > > TCG instead of KVM, i.e. a big endian powerpc kernel guest on x86_64
> > > little endian host ?
> > 
> > TCG does not yet support irqfd/ioeventfd, so it cannot be used with vhost.
> > 
> > Paolo
> 
> vhost does not require irqfd anymore.  I think ioeventfd actually works
> fine though I didn't try, it would be easy to support.

That's an interesting issue, thanks for pointing this out, Laurent! So
do we now rather want to leave everything as it currently is, in case
somebody wants to use vhost-net with a cross-endian TCG guest one day?

Or do we assume that either
a) TCG is so slow anyway that nobody wants to accelerate it with vhost
or
b) TCG vhost likely won't happen that soon so we hope that everybody
will already be using virtio 1.0 at that point in time (with a fixed
endianness) 
?
... then I think we should go on and include this patch.

 Thomas
