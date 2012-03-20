From: "Indan Zupancic" <indan@nul.nu>
Subject: [PATCH] net: bpf_jit: Document evilness of negative indirect loads
Date: Tue, 20 Mar 2012 11:16:07 +1100
Message-ID: <307ecac228a1c44930e18777578cbfcd.squirrel@webmail.greenhost.nl>
References: <1331587715-26069-1-git-send-email-wad@chromium.org>
    <0c55cb258e0b5bbd615923ee2a9f06b9.squirrel@webmail.greenhost.nl>
    <1331658828.4449.16.camel@edumazet-glaptop>
    <3e4fc1efb5d7dbe0dd966e3192e84645.squirrel@webmail.greenhost.nl>
    <1331704535.2456.37.camel@edumazet-laptop>
    <3f56b0860272f4ca8925c0a249a30539.squirrel@webmail.greenhost.nl>
    <1331712357.2456.58.camel@edumazet-laptop>
    <7a1c4974e8fbc3b82ead0bfb18224d5b.squirrel@webmail.greenhost.nl>
    <1331992184.2466.45.camel@edumazet-laptop>
    <9a0230cb8db556cc9cf5d1f6b2439fb5.squirrel@webmail.greenhost.nl>
    <1332074448.3722.25.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David Miller" <davem@davemloft.net>,
	"Will Drewry" <wad@chromium.org>, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,
	kernel-hardening@lists.openwall.com, netdev@vger.kernel.org,
	x86@kernel.org, arnd@arndb.de, hpa@zytor.com, mingo@redhat.com,
	oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu,
	eparis@redhat.com, serge.hallyn@canonical.com, djm@mindrot.org,
	scarybeasts@gmail.com, pmoore@redhat.com,
	akpm@linux-foundation.org, corbet@lwn.net, markus@chromium.org,
	coreyb@linux.vnet.ibm.com, keescook@chromium.org,
	"Matt Evans" <matt@ozlabs.org>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <1332074448.3722.25.camel@edumazet-laptop>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, March 18, 2012 23:40, Eric Dumazet wrote:
> Le dimanche 18 mars 2012 =C3=A0 19:35 +1100, Indan Zupancic a =C3=A9c=
rit :
>
>> And in the 00.00001% case that the filter uses a computed negative
>> offset the BPF JIT fails at runtime. So to not be buggy you need at
>> least a call to __load_pointer() for the negative case.
>
> Please show me how and why a real (I mean useful one...) filter could
> generate a dynamic negative value, and I'll change the code.
>
>
> Negative values are there to allow access to network/mac header
> components. I cant see how a BPF code could have a valid use of dynam=
ic
> indexes in these headers.

E.g. when poking in a variable length IP header with a filter
attached to a TCP/UDP socket. Still a bit far fetched though.

>
> Right now we consider such code is evil and filter does "return 0"
> saying so.

I'm fine with that, but this should be documented somewhere I think.

Greetings,

Indan


[PATCH] net: bpf_jit: Document evilness of negative indirect loads

Negative offsets are used to access ancillary data. In the case of
SKF_NET_OFF and SKF_LL_OFF users may expect negative indirect loads
to work. If BPF JIT is used then such loads will fail. In any case,
negative indirect loads are considered evil and are not supported.

---

Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Indan Zupancic <indan@nul.nu>

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 8eeb205..2bd4bbb 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -114,6 +114,9 @@ struct sock_fprog {	/* Required for SO_ATTACH_FILTE=
R. */
    We use them to reference ancillary data.
    Unlike introduction new instructions, it does not break
    existing compilers/optimizers.
+
+   Do not expect negative indirect loads to work, they are
+   considered evil.
  */
 #define SKF_AD_OFF    (-0x1000)
 #define SKF_AD_PROTOCOL 0
