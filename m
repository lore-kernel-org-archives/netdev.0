From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: linux-next: Tree for April 29 (bpf_jit)
Date: Fri, 29 Apr 2011 19:19:18 +0200
Message-ID: <1304097558.2686.6.camel@edumazet-laptop>
References: <20110429131940.4f4c938f.sfr@canb.auug.org.au>
	 <20110429092632.26ff1e53.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	netdev <netdev@vger.kernel.org>, linux-next@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Randy Dunlap <randy.dunlap@oracle.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110429092632.26ff1e53.randy.dunlap@oracle.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 29 avril 2011 =C3=A0 09:26 -0700, Randy Dunlap a =C3=A9crit=
 :
> On Fri, 29 Apr 2011 13:19:40 +1000 Stephen Rothwell wrote:
>=20
> > Hi all,
> >=20
> > Changes since 20110428:
>=20
>=20
> when CONFIG_MODULES is not enabled:
>=20
> bpf_jit_comp.c:(.text+0x43cc2): undefined reference to `module_free'
> (.text+0x4521a): undefined reference to `module_alloc'
> (.text+0x453af): undefined reference to `module_free'
>=20
>=20

Oh well, I guess we can add one 'depends on MODULES' like we do for
KPROBES (it also uses module_alloc())

Not sure many people build a !CONFIG_MODULES kernel these days...

Thanks Randy !

[PATCH net-next-2.6] bpf: depends on MODULES

module_alloc() and module_free() are available only if CONFIG_MODULES=3D=
y

Reported-by: Randy Dunlap <randy.dunlap@oracle.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/Kconfig |    1 +
 1 files changed, 1 insertion(+)

diff --git a/net/Kconfig b/net/Kconfig
index 745fb02..878151c 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -238,6 +238,7 @@ config HAVE_BPF_JIT
 config BPF_JIT
 	bool "enable BPF Just In Time compiler"
 	depends on HAVE_BPF_JIT
+	depends on MODULES
 	---help---
 	  Berkeley Packet Filter filtering capabilities are normally handled
 	  by an interpreter. This option allows kernel to generate a native
