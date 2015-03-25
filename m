From: Richard Weinberger <richard@nod.at>
Subject: Re: [RFC PATCH 00/11] an introduction of library operating system
 for Linux (LibOS)
Date: Wed, 25 Mar 2015 23:50:23 +0100
Message-ID: <55133BAF.30301@nod.at>
References: <1427202642-1716-1-git-send-email-tazaki@sfc.wide.ad.jp>	<551164ED.5000907@nod.at>	<m2twxacw13.wl@sfc.wide.ad.jp>	<55117565.6080002@nod.at>	<m2sicuctb2.wl@sfc.wide.ad.jp>	<55118277.5070909@nod.at> <m2bnjhcevt.wl@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: linux-arch@vger.kernel.org, arnd@arndb.de, corbet@lwn.net,
	cl@linux.com, penberg@kernel.org, rientjes@google.com,
	iamjoonsoo.kim@lge.com, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org,
	netdev@vger.kernel.org, linux-mm@kvack.org, jdike@addtoit.com,
	rusty@rustcorp.com.au, mathieu.lacage@gmail.com
To: Hajime Tazaki <tazaki@sfc.wide.ad.jp>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <m2bnjhcevt.wl@sfc.wide.ad.jp>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

Am 25.03.2015 um 15:48 schrieb Hajime Tazaki:
> 
> At Tue, 24 Mar 2015 16:27:51 +0100,
> Richard Weinberger wrote:
>>
>> I'd say you should try hard to re-use/integrate your work in arch/um.
>> With um we already have an architecture which targets userspace,
>> having two needs a very good justification.
> 
> in addition to the case of my previous email, libos is not
> limited to run on user-mode: it is just a library which can
> be used with various programs. thus it has a potential (not
> implemented yet) to run on a hypervisor like OSv or MirageOS
> does for application containment, or run on a bare-metal
> machine as rumpkernel does. We already have a clear
> interface for the underlying layer to be able to add such
> backend.
> 
> again, it's not only for user-mode.
> 
> mixing all the stuff in a single architecture may not only
> mislead to users, but also introduce conceptual-disagreements
> during code sharing of essential parts. 
> 
> I don't see any benefits to have a name 'um' with this idea.
> 
> # I'm not saying sharing a part of code is bad idea at all, btw.

After digging into the source I know what you mean and I have the
feeling that "lib" is the wrong name.
It has not much do to with an architecture.
Apart from that, I really like your idea!

You don't implement an architecture, you take some part of Linux
(the networking stack) and create stubs around it to make it work.
That means that we'd also have to duplicate kernel functions into
arch/lib to keep it running.

BTW: It does not build here:
---cut---
  LIB           liblinux-4.0.0-rc5.so
Cloning into 'arch/lib/tools'...
remote: Counting objects: 93, done.
remote: Compressing objects: 100% (19/19), done.
remote: Total 93 (delta 9), reused 0 (delta 0), pack-reused 74
Receiving objects: 100% (93/93), 59.77 KiB | 0 bytes/s, done.
Resolving deltas: 100% (43/43), done.
Checking connectivity... done
  CC       nuse-fiber.o
  CC       nuse-vif.o
  CC       nuse-hostcalls.o
  CC       nuse-config.o
  CC       nuse-vif-rawsock.o
  CC       nuse-vif-tap.o
  CC       nuse-glue.o
  CC       nuse-vif-pipe.o
  CC       nuse.o
make[2]: *** No rule to make target `rump/lib/librumpuser/rumpuser_sp.c', needed by `rump/lib/librumpuser/rumpuser_sp.o'.  Stop.
make[2]: *** Waiting for unfinished jobs....
  CC       sim.o
  GEN      git-sparse
make[2]: *** No rule to make target `rump/lib/librumpclient/rumpclient.c', needed by `rump/lib/librumpclient/rumpclient.o'.  Stop.
make[1]: *** [librumpclient.so] Error 2
make[1]: *** Waiting for unfinished jobs....
nuse.c: In function 'nuse_dev_rx':
nuse.c:279:5: warning: unused variable 'hdr' [-Wunused-variable]
  } *hdr = (struct ethhdr *)buf;
     ^
make[1]: *** [librumpserver.so] Error 2
make: *** [arch/lib/tools] Error 2
---cut---

Thanks,
//richard
