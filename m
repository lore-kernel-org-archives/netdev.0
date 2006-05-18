From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Bugme-new] [Bug 6579] New: Kernel Oops, IRDA stack related
Date: Thu, 18 May 2006 11:41:13 -0700
Message-ID: <20060518114113.39e3539c.akpm@osdl.org>
References: <200605181710.k4IHA3PH021040@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Samuel Ortiz <samuel.ortiz@nokia.com>,
	Christoph Hellwig <hch@lst.de>, zilvinas@gemtek.lt
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:39372 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751373AbWERSly (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 May 2006 14:41:54 -0400
To: bugme-daemon@bugzilla.kernel.org
In-Reply-To: <200605181710.k4IHA3PH021040@fire-2.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

bugme-daemon@bugzilla.kernel.org wrote:
>
> http://bugzilla.kernel.org/show_bug.cgi?id=6579
> 
>            Summary: Kernel Oops, IRDA stack related
>     Kernel Version: v2.6.16.16 + squashfs v3.0 patch
>             Status: NEW
>           Severity: normal
>              Owner: drivers_other@kernel-bugs.osdl.org
>          Submitter: zilvinas@gemtek.lt
> 
> 
> Most recent kernel where this bug did not occur:
> v2.6.16.16 - haven't tried earlier versions. Just now started using IRDA for
> phone management.
> 
> Distribution:
> Debian Unstable/Uptodate. Kernel is vanilla v2.6.16.16 + squashfs 3.0 patch
> applied. Otherwise clean tree.
> 
> Hardware Environment:
> Evo N800v, 
> Software Environment:
> Linux huh 2.6.16.16-evo #1 Fri May 12 12:17:14 EEST 2006 i686 GNU/Linux
>  
> Gnu C                  4.0.4
> Gnu make               3.81
> binutils               2.16.91
> util-linux             2.12r
> mount                  2.12r
> module-init-tools      3.2.2
> e2fsprogs              1.39-WIP
> reiserfsprogs          3.6.19
> xfsprogs               2.7.16
> pcmcia-cs              3.2.8
> nfs-utils              1.0.7
> Linux C Library        2.3.6
> Dynamic linker (ldd)   2.3.6
> Procps                 3.2.6
> Net-tools              1.60
> Console-tools          0.2.3
> Sh-utils               5.94
> udev                   092
> Modules Loaded         option radeon drm nfsd lockd sunrpc ipv6 deflate
> zlib_deflate zlib_inflate twofish serpent aes blowfish des sha256 sha1 md5
> crypto_null dm_mod irnet ppp_generic slhc irlan ircomm_tty ircomm pl2303
> usbserial pcmcia firmware_class snd_intel8x0 snd_ac97_codec snd_ac97_bus
> snd_pcm_oss snd_mixer_oss irtty_sir sir_dev pcspkr snd_pcm snd_timer irda
> 8250_pnp ohci_hcd ide_cd crc_ccitt floppy ehci_hcd 8250 serial_core yenta_socket
> cdrom snd rsrc_nonstatic soundcore pcmcia_core snd_page_alloc intel_agp agpgart
> 
> Problem Description:
> 
> Recently I've started using IRDA, to manage phone/calendar & co on Nokia 6310
> phone. For this task I am using IRDA and xgnokii management software. Sometimes
> for no reason I am getting oopses at random addresses. System is not locking up
> or so. It always prints oops followed by messages :
> 
> May 14 00:40:52 huh kernel:  <1>Fixing recursive fault but reboot is needed!
> 
> After reboot it takes again some time - ooops is reported at different location
> (mostly random, but backtrace is same).
> 
> Steps to reproduce:
> It is quite simple, attempt to download phonebook, calendar, then attempt to
> upload. Sometimes it happens during logo download/upload.  
> 
> Oops will be added in the next comments.
> 

It's hitting list_head poisoning in
irda_release->sock_def_wakeup->__wake_up_common.

Appears to be a post-2.6.16 regression.

