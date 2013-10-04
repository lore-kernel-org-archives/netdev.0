From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH v3 net-next] fix unsafe set_memory_rw from softirq
Date: Fri, 4 Oct 2013 06:56:29 -0700
Message-ID: <CANn89iKkbR0_HaofvC_OVvqRv_Hqj3rATx-Z_4xXeusOasa56g@mail.gmail.com>
References: <1380853446-30537-1-git-send-email-ast@plumgrid.com>
 <20131004075133.GA12313@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6181738457069530019=="
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>,
 Paul Mackerras <paulus@samba.org>, "H. Peter Anvin" <hpa@zytor.com>,
 sparclinux@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>,
 Alexei Starovoitov <ast@plumgrid.com>, linux-s390@vger.kernel.org,
 Russell King <linux@arm.linux.org.uk>, x86@kernel.org,
 James Morris <jmorris@namei.org>, Ingo Molnar <mingo@redhat.com>,
 Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
 "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Xi Wang <xi.wang@gmail.com>,
 Matt Evans <matt@ozlabs.org>, Thomas Gleixner <tglx@linutronix.de>,
 linux-arm-kernel@lists.infradead.org, Stelian Nirlu <steliannirlu@gmail.com>,
 Nicolas Schichan <nschichan@freebox.fr>,
 Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, netdev <netdev@vger.kernel.org>,
 linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
 Mircea Gherzan <mgherzan@gmail.com>, Daniel Borkmann <
To: Ingo Molnar <mingo@kernel.org>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <20131004075133.GA12313@gmail.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

--===============6181738457069530019==
Content-Type: multipart/alternative; boundary=047d7b67807058f43a04e7eaabc3

--047d7b67807058f43a04e7eaabc3
Content-Type: text/plain; charset=ISO-8859-1

1)
>
> I took a brief look at arch/x86/net/bpf_jit_comp.c while reviewing this
> patch.
>
> You need to split up bpf_jit_compile(), it's an obscenely large, ~600
> lines long function. We don't do that in modern, maintainable kernel code.
>
> 2)
>
> This 128 bytes extra padding:
>
>         /* Most of BPF filters are really small,
>          * but if some of them fill a page, allow at least
>          * 128 extra bytes to insert a random section of int3
>          */
>         sz = round_up(proglen + sizeof(*header) + 128, PAGE_SIZE);
>
> why is it done? It's not clear to me from the comment.
>

commit 314beb9bcabfd6b4542ccbced2402af2c6f6142a
Author: Eric Dumazet <edumazet@google.com>
Date:   Fri May 17 16:37:03 2013 +0000

    x86: bpf_jit_comp: secure bpf jit against spraying attacks

    hpa bringed into my attention some security related issues
    with BPF JIT on x86.

    This patch makes sure the bpf generated code is marked read only,
    as other kernel text sections.

    It also splits the unused space (we vmalloc() and only use a fraction of
    the page) in two parts, so that the generated bpf code not starts at a
    known offset in the page, but a pseudo random one.

    Refs:

http://mainisusuallyafunction.blogspot.com/2012/11/attacking-hardened-linux-systems-with.html

--047d7b67807058f43a04e7eaabc3
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_extra"><br><br><div class=3D"gmail_quo=
te"><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;bor=
der-left-width:1px;border-left-color:rgb(204,204,204);border-left-style:sol=
id;padding-left:1ex">

1)<br>
<br>
I took a brief look at arch/x86/net/bpf_jit_comp.c while reviewing this<br>
patch.<br>
<br>
You need to split up bpf_jit_compile(), it&#39;s an obscenely large, ~600<b=
r>
lines long function. We don&#39;t do that in modern, maintainable kernel co=
de.<br>
<br>
2)<br>
<br>
This 128 bytes extra padding:<br>
<br>
=A0 =A0 =A0 =A0 /* Most of BPF filters are really small,<br>
=A0 =A0 =A0 =A0 =A0* but if some of them fill a page, allow at least<br>
=A0 =A0 =A0 =A0 =A0* 128 extra bytes to insert a random section of int3<br>
=A0 =A0 =A0 =A0 =A0*/<br>
=A0 =A0 =A0 =A0 sz =3D round_up(proglen + sizeof(*header) + 128, PAGE_SIZE)=
;<br>
<br>
why is it done? It&#39;s not clear to me from the comment.<br></blockquote>=
<div><br></div><div>commit 314beb9bcabfd6b4542ccbced2402af2c6f6142a</div><d=
iv>Author: Eric Dumazet &lt;<a href=3D"mailto:edumazet@google.com">edumazet=
@google.com</a>&gt;</div>
<div>Date: =A0 Fri May 17 16:37:03 2013 +0000</div><div><br></div><div>=A0 =
=A0 x86: bpf_jit_comp: secure bpf jit against spraying attacks</div><div>=
=A0 =A0=A0</div><div>=A0 =A0 hpa bringed into my attention some security re=
lated issues</div>
<div>=A0 =A0 with BPF JIT on x86.</div><div>=A0 =A0=A0</div><div>=A0 =A0 Th=
is patch makes sure the bpf generated code is marked read only,</div><div>=
=A0 =A0 as other kernel text sections.</div><div>=A0 =A0=A0</div><div>=A0 =
=A0 It also splits the unused space (we vmalloc() and only use a fraction o=
f</div>
<div>=A0 =A0 the page) in two parts, so that the generated bpf code not sta=
rts at a</div><div>=A0 =A0 known offset in the page, but a pseudo random on=
e.</div><div>=A0 =A0=A0</div><div>=A0 =A0 Refs:</div><div>=A0 =A0 <a href=
=3D"http://mainisusuallyafunction.blogspot.com/2012/11/attacking-hardened-l=
inux-systems-with.html">http://mainisusuallyafunction.blogspot.com/2012/11/=
attacking-hardened-linux-systems-with.html</a></div>
<div>=A0 =A0=A0</div><div>=A0</div></div></div></div>

--047d7b67807058f43a04e7eaabc3--

--===============6181738457069530019==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linuxppc-dev mailing list
Linuxppc-dev@lists.ozlabs.org
https://lists.ozlabs.org/listinfo/linuxppc-dev
--===============6181738457069530019==--
