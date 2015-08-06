From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [Xen-devel] printk from softirq on xen: hard lockup
Date: Thu, 6 Aug 2015 18:21:32 +0200
Message-ID: <CAHmME9r34QsbC-RuTw40PVOD-H7zQRwvPo0gdtesyV-V05vccA@mail.gmail.com>
References: <CAHmME9rUdafnjz0ej-z_cgznMrj27SJgy6v8GJXM0qGfUpWaMQ@mail.gmail.com>
	<55C0F291.7060806@citrix.com>
	<CAHmME9r6yYyiRXD7hyyvZnk9CvNAxgG5MSb=F=smSV6+j_U_FQ@mail.gmail.com>
	<55C330C7.6050204@citrix.com>
	<CAHmME9r1Ugk65OWgATh-aqW9s9QDpC8zckgP180vTAFj32wP9w@mail.gmail.com>
	<55C386E9.6060806@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ian Campbell <ian.campbell@citrix.com>, netdev@vger.kernel.org,
	Paul McKenney <paulmck@linux.vnet.ibm.com>,
	linux-kernel@vger.kernel.org, xen-devel@lists.xen.org
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55C386E9.6060806@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In that case, it doesn't compile.

arch/x86/xen/apic.c:204:13: error: redefinition of =E2=80=98xen_init_ap=
ic=E2=80=99
 void __init xen_init_apic(void)
             ^
In file included from arch/x86/xen/apic.c:9:0:
arch/x86/xen/xen-ops.h:110:27: note: previous definition of
=E2=80=98xen_init_apic=E2=80=99 was here
 static inline void __init xen_init_apic(void)

It looks like whoever wrote this explicitly didn't want that APIC
driver used on domU:

#ifdef CONFIG_XEN_DOM0
void __init xen_init_vga(const struct dom0_vga_console_info *, size_t s=
ize);
void __init xen_init_apic(void);
#else
static inline void __init xen_init_vga(const struct dom0_vga_console_in=
fo *info,
                                       size_t size)
{
}
static inline void __init xen_init_apic(void)
{
}
#endif
