From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH FINAL] Merge the Sonics Silicon Backplane subsystem
Date: Wed, 1 Aug 2007 11:33:36 +0200
Message-ID: <200708011133.37214.mb@bu3sch.de>
References: <200707291324.58691.mb@bu3sch.de> <20070731202648.e1a8c45f.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Gary Zambrano <zambrano-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070731202648.e1a8c45f.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wednesday 01 August 2007, Andrew Morton wrote:
> On Sun, 29 Jul 2007 13:24:54 +0200 Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org> wrote:
> 
> > The Sonics Silicon Backplane is a mini-bus used on
> > various Broadcom chips and embedded devices.
> 
> Sigh.
> 
> s390:
> 
> drivers/ssb/main.c: In function 'ssb_ssb_read16':
> drivers/ssb/main.c:489: error: implicit declaration of function 'readw'
> drivers/ssb/main.c: In function 'ssb_ssb_read32':
> drivers/ssb/main.c:497: error: implicit declaration of function 'readl'
> drivers/ssb/main.c: In function 'ssb_ssb_write16':
> drivers/ssb/main.c:505: error: implicit declaration of function 'writew'
> drivers/ssb/main.c: In function 'ssb_ssb_write32':
> drivers/ssb/main.c:513: error: implicit declaration of function 'writel'        
> 
> we shouldn't be compiling SSB on s390, because:
> 
> config SSB
>         tristate "Sonics Silicon Backplane support"
>         depends on EXPERIMENTAL && HAS_IOMEM
> 
> and
> 
> akpm2:/usr/src/25> grep IOMEM .config 
> CONFIG_NO_IOMEM=y
> akpm2:/usr/src/25> 
> 
> but
> 
> akpm2:/usr/src/25> grep SSB .config 
> CONFIG_DCSSBLK=m
> CONFIG_SSB=m
> CONFIG_SSB_SILENT=y
> 
> well, how did that come about?
> 
> It _has_ to be `select'.  It's _always_ `select'.
> 
> yup, it's `select':
> 
> Selected by: B44 && NETDEVICES && NET_ETHERNET || BCM43XX_MAC80211 && NETDEVICES && !S390 && MAC80211 && WLAN_80211 && EXPERIMENTAL
> 
> 
> Look.  Kconfig's `select' Just.  Does.  Not.  Work.  If you find yourself
> contemplating using it, please, don sackcloth, take a cold shower and
> several analgesics, then have another go, OK?
> 
> ho hum.

Ah, yeah. Crap select not caring about dependencies...
The problem is that people will kill me, if they don't find
bcm43xx in the kconfig anymore, as they have to enable ssb
before that. Ya know the flame with Uwe Bugla going crazy
about that? :D
Same goes for b44. It was always there in kconfig without
additional deps, but now (when we merge the b44 port) we would
need ssb selected before we see b44.
Maybe default SSB to M?
