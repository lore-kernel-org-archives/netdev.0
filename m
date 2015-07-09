From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] KVM: Add Kconfig option to signal cross-endian guests
Date: Thu, 9 Jul 2015 16:07:47 +0300
Message-ID: <20150709160626-mutt-send-email-mst@redhat.com>
References: <20150707195012-mutt-send-email-mst@redhat.com>
	<1436428145-29823-1-git-send-email-thuth@redhat.com>
	<559E435E.9050608@redhat.com> <559E6FBD.5050502@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Laurent Vivier <lvivier@redhat.com>, Thomas Huth <thuth@redhat.com>,
	kvm@vger.kernel.org, Gleb Natapov <gleb@kernel.org>,
	linux-kernel@vger.kernel.org, kvm-ppc@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Marc Zyngier <marc.zyngier@arm.com>, Paul Mackerras <paulus@samba.org>,
	Christoffer Dall <christoffer.dall@linaro.org>, netdev@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org
To: Paolo Bonzini <pbonzini@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <559E6FBD.5050502@redhat.com>
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

On Thu, Jul 09, 2015 at 02:57:33PM +0200, Paolo Bonzini wrote:
> 
> 
> On 09/07/2015 11:48, Laurent Vivier wrote:
> > 
> > 
> > On 09/07/2015 09:49, Thomas Huth wrote:
> >> The option for supporting cross-endianness legacy guests in
> >> the vhost and tun code should only be available on systems
> >> that support cross-endian guests.
> > 
> > I'm sure I misunderstand something, but what happens if we use QEMU with
> > TCG instead of KVM, i.e. a big endian powerpc kernel guest on x86_64
> > little endian host ?
> 
> TCG does not yet support irqfd/ioeventfd, so it cannot be used with vhost.
> 
> Paolo

vhost does not require irqfd anymore.  I think ioeventfd actually works
fine though I didn't try, it would be easy to support.


> > Do you forbid the use of vhost in this case ?
> > 
> >> Signed-off-by: Thomas Huth <thuth@redhat.com>
> >> ---
> >>  arch/arm/kvm/Kconfig     | 1 +
> >>  arch/arm64/kvm/Kconfig   | 1 +
> >>  arch/powerpc/kvm/Kconfig | 1 +
> >>  drivers/net/Kconfig      | 1 +
> >>  drivers/vhost/Kconfig    | 1 +
> >>  virt/kvm/Kconfig         | 3 +++
> >>  6 files changed, 8 insertions(+)
> >>
> >> diff --git a/arch/arm/kvm/Kconfig b/arch/arm/kvm/Kconfig
> >> index bfb915d..9d8f363 100644
> >> --- a/arch/arm/kvm/Kconfig
> >> +++ b/arch/arm/kvm/Kconfig
> >> @@ -31,6 +31,7 @@ config KVM
> >>  	select KVM_VFIO
> >>  	select HAVE_KVM_EVENTFD
> >>  	select HAVE_KVM_IRQFD
> >> +	select KVM_CROSS_ENDIAN_GUESTS
> >>  	depends on ARM_VIRT_EXT && ARM_LPAE && ARM_ARCH_TIMER
> >>  	---help---
> >>  	  Support hosting virtualized guest machines.
> >> diff --git a/arch/arm64/kvm/Kconfig b/arch/arm64/kvm/Kconfig
> >> index bfffe8f..9af39fe 100644
> >> --- a/arch/arm64/kvm/Kconfig
> >> +++ b/arch/arm64/kvm/Kconfig
> >> @@ -31,6 +31,7 @@ config KVM
> >>  	select KVM_VFIO
> >>  	select HAVE_KVM_EVENTFD
> >>  	select HAVE_KVM_IRQFD
> >> +	select KVM_CROSS_ENDIAN_GUESTS
> >>  	---help---
> >>  	  Support hosting virtualized guest machines.
> >>  
> >> diff --git a/arch/powerpc/kvm/Kconfig b/arch/powerpc/kvm/Kconfig
> >> index 3caec2c..e028710 100644
> >> --- a/arch/powerpc/kvm/Kconfig
> >> +++ b/arch/powerpc/kvm/Kconfig
> >> @@ -79,6 +79,7 @@ config KVM_BOOK3S_64_HV
> >>  	select KVM_BOOK3S_HV_POSSIBLE
> >>  	select MMU_NOTIFIER
> >>  	select CMA
> >> +	select KVM_CROSS_ENDIAN_GUESTS
> >>  	---help---
> >>  	  Support running unmodified book3s_64 guest kernels in
> >>  	  virtual machines on POWER7 and PPC970 processors that have
> >> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> >> index c18f9e6..0c4ce47 100644
> >> --- a/drivers/net/Kconfig
> >> +++ b/drivers/net/Kconfig
> >> @@ -261,6 +261,7 @@ config TUN
> >>  config TUN_VNET_CROSS_LE
> >>  	bool "Support for cross-endian vnet headers on little-endian kernels"
> >>  	default n
> >> +	depends on KVM_CROSS_ENDIAN_GUESTS
> >>  	---help---
> >>  	  This option allows TUN/TAP and MACVTAP device drivers in a
> >>  	  little-endian kernel to parse vnet headers that come from a
> >> diff --git a/drivers/vhost/Kconfig b/drivers/vhost/Kconfig
> >> index 533eaf0..4d8ae6b 100644
> >> --- a/drivers/vhost/Kconfig
> >> +++ b/drivers/vhost/Kconfig
> >> @@ -35,6 +35,7 @@ config VHOST
> >>  
> >>  config VHOST_CROSS_ENDIAN_LEGACY
> >>  	bool "Cross-endian support for vhost"
> >> +	depends on KVM_CROSS_ENDIAN_GUESTS
> >>  	default n
> >>  	---help---
> >>  	  This option allows vhost to support guests with a different byte
> >> diff --git a/virt/kvm/Kconfig b/virt/kvm/Kconfig
> >> index e2c876d..cc7b28a 100644
> >> --- a/virt/kvm/Kconfig
> >> +++ b/virt/kvm/Kconfig
> >> @@ -47,3 +47,6 @@ config KVM_GENERIC_DIRTYLOG_READ_PROTECT
> >>  config KVM_COMPAT
> >>         def_bool y
> >>         depends on COMPAT && !S390
> >> +
> >> +config KVM_CROSS_ENDIAN_GUESTS
> >> +       bool
> >>
