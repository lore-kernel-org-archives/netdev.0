From: chengong <g.chen@freescale.com>
Subject: Re: modpost warning question
Date: Wed, 25 Jul 2007 18:08:03 +0800
Message-ID: <1185358083.4996.6.camel@localhost.localdomain>
References: <Pine.LNX.4.64.0707250210520.14366@blarg.am.freescale.net>
	<20070725072712.GB24093@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	Jeff Garzik <jeff@garzik.org>, linux-kernel@vger.kernel.org
To: Sam Ravnborg <sam@ravnborg.org>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <20070725072712.GB24093@uranus.ravnborg.org>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-07-25 at 09:27 +0200, Sam Ravnborg wrote:
> On Wed, Jul 25, 2007 at 02:14:12AM -0500, Kumar Gala wrote:
> > I'm seeing the following warning:
> > 
> > WARNING: vmlinux.o(.init.text+0x1acdc): Section mismatch: reference to
> > .exit.text:gfar_mdio_exit (between 'gfar_init' and 'gfar_mdio_init')
> > 
> > I don't understand why its not ok to access .exit.text from .init.text
> 
> Several architectures discards .exit.text in the final linker
> script (arch/$(ARCH)/kernel/vmlinux.lds.S
> 
> So any references to .exit.text will when a module is build-in result
> in a linker error because ld will flag it as an error when we reference
> a symbol in a discarded section.
But why? Just make kernel size smaller?
> 
> For the popular architectures (i386,x86_64) we discard .exit.text at
> runtime so here we do not see the error from ld (sadly).
>From which version? On my machine I have seen the same problem when
building i386 target with the version 2.6.21.
> 
> 	Sam
> _______________________________________________
> Linuxppc-dev mailing list
> Linuxppc-dev@ozlabs.org
> https://ozlabs.org/mailman/listinfo/linuxppc-dev
