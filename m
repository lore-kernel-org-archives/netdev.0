From: Shubham Bansal <illusionist.neo@gmail.com>
Subject: arch: arm: bpf: Converting cBPF to eBPF for arm 32 bit
Date: Mon, 30 Jan 2017 15:46:47 +0530
Message-ID: <CAHgaXdJW=-tprZtBcWBWxM1En-aCp4B++3DmoRyDKVAtqY6uuA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary=001a114116f2fc73db05474d1c86
Cc: netdev@vger.kernel.org, kernel-hardening@lists.openwall.com,
	linux@armlinux.org.uk, linux-arm-kernel@lists.infradead.org
To: Kees Cook <keescook@chromium.org>, Daniel Borkmann <daniel@iogearbox.net>,
	Mircea Gherzan <mgherzan@gmail.com>
Return-path: <kernel-hardening-return-6193-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
List-Id: netdev.vger.kernel.org

--001a114116f2fc73db05474d1c86
Content-Type: text/plain; charset=UTF-8

Hi all,

Just starting a new thread with proper heading on the main kernel hardening
and net-dev mailing list so that other people can be involved in this.
Please don't take this as a personal mail.

I am working on conversion of arm32 cBPF into eBPF JIT. I wanted some help,
regarding understanding of kernel code, from the dev available on the
mailing list. If you look at the ./arch/arm/net/bpf_jit_32.c code, you will
see jit_ctx structure. If anybody could help me understand what each fields
of this structure represent then it would be great.

Also, currently I am mapping the eBPF registers to arm 32 bit registers in
the following way.

static const int bpf2a32[] = {
>
>         /* return value from in-kernel function, and exit value from eBPF
> */
>         [BPF_REG_0] = ARM_R0,
>
>         /* arguments from eBPF program to in-kernel function */
>
>         [BPF_REG_1] = ARM_R1,
>
>         [BPF_REG_2] = ARM_R2,
>
>         [BPF_REG_3] = ARM_R3,
>
>         [BPF_REG_4] = ARM_R4,
>
>         [BPF_REG_5] = ARM_R5,
>
>         /* callee saved registers that in-kernel function will preserve */
>
>         [BPF_REG_6] = ARM_R6,
>
>         [BPF_REG_7] = ARM_R7,
>
>         [BPF_REG_8] = ARM_R8,
>
>         [BPF_REG_9] = ARM_R9,
>
>         /* Read only Frame Pointer to access Stack */
>
>         [BPF_REG_FP] = ARM_FP,
>
>         /* Temperory Register for internal BPF JIT */
>
>         [TMP_REG_1] = ARM_R11,
>
>         /* temporary register for blinding constants */
>
>         [BPF_REG_AX] = ARM_R10,
>
> };


But I have some question if anybody could help with those.

   - Currently, as eBPF uses 64 bit registers, I am mapping 64 bit eBPF
   registers with 32 bit arm registers which looks wrong to me. Do anybody
   have some idea about how to map eBPF->arm 32 bit registers ?
   - Also, is my current mapping good enough to make the JIT fast enough ?
   because as you might know, eBPF JIT mostly depends on 1-to-1 mapping of its
   instructions with native instructions.


Appreciate the help from anybody from the mailing list.

Best,
Shubham Bansal

--001a114116f2fc73db05474d1c86
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hi all,<div><br></div><div>Just starting a new thread with=
 proper heading on the main kernel hardening and net-dev mailing list so th=
at other people can be involved in this. Please don&#39;t take this as a pe=
rsonal mail.</div><div><br></div><div>I am working on conversion of arm32 c=
BPF into eBPF JIT. I wanted some help, regarding understanding of kernel co=
de, from the dev available on the mailing list. If you look at the ./arch/a=
rm/net/bpf_jit_32.c code, you will see jit_ctx structure. If anybody could =
help me understand what each fields of this structure represent then it wou=
ld be great.</div><div><br></div><div>Also, currently I am mapping the eBPF=
 registers to arm 32 bit registers in the following way.</div><div><br></di=
v><div>







<blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-=
left:1px solid rgb(204,204,204);padding-left:1ex"><font face=3D"arial, helv=
etica, sans-serif" size=3D"1"><span class=3D"gmail-s1">static</span><span c=
lass=3D"gmail-s2"> </span><span class=3D"gmail-s1">const</span><span class=
=3D"gmail-s2"> </span><span class=3D"gmail-s1">int</span><span class=3D"gma=
il-s2"> bpf2a32[] =3D {=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 </span><span class=3D"gmai=
l-s3">=C2=A0<br></span></font><font face=3D"arial, helvetica, sans-serif" s=
ize=3D"1"><span class=3D"gmail-s4">=C2=A0 =C2=A0 =C2=A0 =C2=A0 </span><span=
 class=3D"gmail-s2">/* return value from in-kernel function, and exit value=
 from eBPF */</span><span class=3D"gmail-s4">=C2=A0 =C2=A0 </span><span cla=
ss=3D"gmail-s3">=C2=A0<br></span></font><font face=3D"arial, helvetica, san=
s-serif" size=3D"1"><span class=3D"gmail-s2">=C2=A0 =C2=A0 =C2=A0 =C2=A0 [B=
PF_REG_0] =3D ARM_R0, =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 </span><span class=3D"gmai=
l-s3">=C2=A0<br></span></font><font face=3D"arial, helvetica, sans-serif" s=
ize=3D"1"><span class=3D"gmail-s4">=C2=A0 =C2=A0 =C2=A0 =C2=A0 </span><span=
 class=3D"gmail-s2">/* arguments from eBPF program to in-kernel function */=
</span><span class=3D"gmail-s4"> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 </span><span class=3D"gmail-s3">=C2=A0<br></span></font><font=
 face=3D"arial, helvetica, sans-serif" size=3D"1"><span class=3D"gmail-s2">=
=C2=A0 =C2=A0 =C2=A0 =C2=A0 [BPF_REG_1] =3D ARM_R1, =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 </span><span class=3D"gmail-s3">=C2=A0<br></span></font><font face=
=3D"arial, helvetica, sans-serif" size=3D"1"><span class=3D"gmail-s2">=C2=
=A0 =C2=A0 =C2=A0 =C2=A0 [BPF_REG_2] =3D ARM_R2, =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 </span><span class=3D"gmail-s3">=C2=A0<br></span></font><font face=3D"a=
rial, helvetica, sans-serif" size=3D"1"><span class=3D"gmail-s2">=C2=A0 =C2=
=A0 =C2=A0 =C2=A0 [BPF_REG_3] =3D ARM_R3, =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 </spa=
n><span class=3D"gmail-s3">=C2=A0<br></span></font><font face=3D"arial, hel=
vetica, sans-serif" size=3D"1"><span class=3D"gmail-s2">=C2=A0 =C2=A0 =C2=
=A0 =C2=A0 [BPF_REG_4] =3D ARM_R4, =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 </span><span=
 class=3D"gmail-s3">=C2=A0<br></span></font><font face=3D"arial, helvetica,=
 sans-serif" size=3D"1"><span class=3D"gmail-s2">=C2=A0 =C2=A0 =C2=A0 =C2=
=A0 [BPF_REG_5] =3D ARM_R5, =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 </span><span class=
=3D"gmail-s3">=C2=A0<br></span></font><font face=3D"arial, helvetica, sans-=
serif" size=3D"1"><span class=3D"gmail-s4">=C2=A0 =C2=A0 =C2=A0 =C2=A0 </sp=
an><span class=3D"gmail-s2">/* callee saved registers that in-kernel functi=
on will preserve */</span><span class=3D"gmail-s4">=C2=A0 =C2=A0 =C2=A0 </s=
pan><span class=3D"gmail-s3">=C2=A0<br></span></font><font face=3D"arial, h=
elvetica, sans-serif" size=3D"1"><span class=3D"gmail-s2">=C2=A0 =C2=A0 =C2=
=A0 =C2=A0 [BPF_REG_6] =3D ARM_R6, =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 </span><span=
 class=3D"gmail-s3">=C2=A0<br></span></font><font face=3D"arial, helvetica,=
 sans-serif" size=3D"1"><span class=3D"gmail-s2">=C2=A0 =C2=A0 =C2=A0 =C2=
=A0 [BPF_REG_7] =3D ARM_R7, =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 </span><span class=
=3D"gmail-s3">=C2=A0<br></span></font><font face=3D"arial, helvetica, sans-=
serif" size=3D"1"><span class=3D"gmail-s2">=C2=A0 =C2=A0 =C2=A0 =C2=A0 [BPF=
_REG_8] =3D ARM_R8, =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 </span><span class=3D"gmail-s=
3">=C2=A0<br></span></font><font face=3D"arial, helvetica, sans-serif" size=
=3D"1"><span class=3D"gmail-s2">=C2=A0 =C2=A0 =C2=A0 =C2=A0 [BPF_REG_9] =3D=
 ARM_R9, =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 </span><span class=3D"gmail-s3">=C2=A0<b=
r></span></font><font face=3D"arial, helvetica, sans-serif" size=3D"1"><spa=
n class=3D"gmail-s4">=C2=A0 =C2=A0 =C2=A0 =C2=A0 </span><span class=3D"gmai=
l-s2">/* Read only Frame Pointer to access Stack */</span><span class=3D"gm=
ail-s4"> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 </span><span class=3D"gmail-s3">=C2=A0<br></span><=
/font><font face=3D"arial, helvetica, sans-serif" size=3D"1"><span class=3D=
"gmail-s2">=C2=A0 =C2=A0 =C2=A0 =C2=A0 [BPF_REG_FP] =3D ARM_FP,=C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 </span><span class=3D"gmail-s3">=C2=A0<br></span></font><=
font face=3D"arial, helvetica, sans-serif" size=3D"1"><span class=3D"gmail-=
s4">=C2=A0 =C2=A0 =C2=A0 =C2=A0 </span><span class=3D"gmail-s2">/* Temperor=
y Register for internal BPF JIT */</span><span class=3D"gmail-s4"> =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 </span><span class=3D"gmail-s3">=C2=A0<br></span></font><font fa=
ce=3D"arial, helvetica, sans-serif" size=3D"1"><span class=3D"gmail-s2">=C2=
=A0 =C2=A0 =C2=A0 =C2=A0 [TMP_REG_1] =3D ARM_R11,=C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 </span><span class=3D"gmail-s3">=C2=A0<br></span></font><font face=3D"a=
rial, helvetica, sans-serif" size=3D"1"><span class=3D"gmail-s4">=C2=A0 =C2=
=A0 =C2=A0 =C2=A0 </span><span class=3D"gmail-s2">/* temporary register for=
 blinding constants */</span><span class=3D"gmail-s4"> =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 </span><spa=
n class=3D"gmail-s3">=C2=A0<br></span></font><font face=3D"arial, helvetica=
, sans-serif" size=3D"1"><span class=3D"gmail-s2">=C2=A0 =C2=A0 =C2=A0 =C2=
=A0 [BPF_REG_AX] =3D ARM_R10, =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 </span><span class=3D"gmai=
l-s3">=C2=A0<br></span></font><span class=3D"gmail-s2"><font face=3D"arial,=
 helvetica, sans-serif" size=3D"1">};=C2=A0</font></span></blockquote><div>=
<br></div><div>But I have some question if anybody could help with those.=
=C2=A0</div><div><ul><li>Currently, as eBPF uses 64 bit registers, I am map=
ping 64 bit eBPF registers with 32 bit arm registers which looks wrong to m=
e. Do anybody have some idea about how to map eBPF-&gt;arm 32 bit registers=
 ?=C2=A0<br></li><li>Also, is my current mapping good enough to make the JI=
T fast enough ? because as you might know, eBPF JIT mostly depends on 1-to-=
1 mapping of its instructions with native instructions.<br></li></ul><div><=
br></div></div><div>Appreciate the help from anybody from the mailing list.=
</div>



















</div><div><br clear=3D"all"><div><div class=3D"gmail_signature"><div dir=
=3D"ltr"><div>Best,<br></div>Shubham Bansal<br></div></div></div>
</div></div>

--001a114116f2fc73db05474d1c86--
