From: Paul Pluzhnikov <ppluzhnikov@google.com>
Subject: Re: [PATCH torvalds/linux.git] Make linux/tcp.h C++ friendly (trivial)
Date: Tue, 6 Mar 2012 16:14:09 -0800
Message-ID: <CALoOobMSXp4x_+En2gyHmpXcxq=sECQvMZN1LX_j3Yve7Ha6Aw@mail.gmail.com>
References: <20111229183002.9B4F4190B09@elbrus2.mtv.corp.google.com> <alpine.LNX.2.00.1202032232320.25026@pobox.suse.cz>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=f46d044287bea8bb3804ba9c0b07
Cc: netdev@vger.kernel.org
To: Jiri Kosina <jkosina@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:44069 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031620Ab2CGAOl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2012 19:14:41 -0500
Received: by wibhm2 with SMTP id hm2so3012670wib.19
        for <netdev@vger.kernel.org>; Tue, 06 Mar 2012 16:14:40 -0800 (PST)
In-Reply-To: <alpine.LNX.2.00.1202032232320.25026@pobox.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--f46d044287bea8bb3804ba9c0b07
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Ping?

I am attaching the patch again so it doesn't get mangled by quoting
and is easier to apply.

Thanks,

On Fri, Feb 3, 2012 at 1:33 PM, Jiri Kosina <jkosina@suse.cz> wrote:
> On Thu, 29 Dec 2011, Paul Pluzhnikov wrote:
>
>> Greetings,
>>
>> Using linux/tcp.h from C++ results in:
>>
>> cat t.cc
>>
>> #include <linux/tcp.h>
>> int main() { }
>>
>> g++ -c t.cc
>>
>> In file included from t.cc:1:
>> /usr/include/linux/tcp.h:72: error: '__u32 __fswab32(__u32)' cannot appe=
ar in a constant-expression
>> /usr/include/linux/tcp.h:72: error: a function call cannot appear in a c=
onstant-expression
>> ...
>
> Paul,
>
> thanks for the patch. I'd however prefer this to go through netdev, not
> feeling like this is fully appropriate for trivial tree.
>
> Adding netdev to CC and keeping the changelog and patch below for
> reference.
>
>>
>> Attached trivial patch fixes this problem.
>>
>> Tested:
>> - the t.cc above compiles with g++ and
>> - the following program generates the same output before/after
>> =A0 the patch:
>>
>> #include <linux/tcp.h>
>> #include <stdio.h>
>>
>> int main ()
>> {
>> #define P(a) printf("%s: %08x\n", #a, (int)a)
>> =A0 P(TCP_FLAG_CWR);
>> =A0 P(TCP_FLAG_ECE);
>> =A0 P(TCP_FLAG_URG);
>> =A0 P(TCP_FLAG_ACK);
>> =A0 P(TCP_FLAG_PSH);
>> =A0 P(TCP_FLAG_RST);
>> =A0 P(TCP_FLAG_SYN);
>> =A0 P(TCP_FLAG_FIN);
>> =A0 P(TCP_RESERVED_BITS);
>> =A0 P(TCP_DATA_OFFSET);
>> #undef P
>> =A0 return 0;
>> }
>>
>> Signed-off-by: Paul Pluzhnikov <ppluzhnikov@google.com>
>>
>>
>> Thanks,
>>
>> P.S. Google has blanket copyright assignment to FSF.
>> --
>> Paul Pluzhnikov
>>
>>
>> diff --git a/include/linux/tcp.h b/include/linux/tcp.h
>> index 7f59ee9..63334f7 100644
>> --- a/include/linux/tcp.h
>> +++ b/include/linux/tcp.h
>> @@ -69,16 +69,16 @@ union tcp_word_hdr {
>> =A0#define tcp_flag_word(tp) ( ((union tcp_word_hdr *)(tp))->words [3])
>>
>> =A0enum {
>> - =A0 =A0 TCP_FLAG_CWR =3D __cpu_to_be32(0x00800000),
>> - =A0 =A0 TCP_FLAG_ECE =3D __cpu_to_be32(0x00400000),
>> - =A0 =A0 TCP_FLAG_URG =3D __cpu_to_be32(0x00200000),
>> - =A0 =A0 TCP_FLAG_ACK =3D __cpu_to_be32(0x00100000),
>> - =A0 =A0 TCP_FLAG_PSH =3D __cpu_to_be32(0x00080000),
>> - =A0 =A0 TCP_FLAG_RST =3D __cpu_to_be32(0x00040000),
>> - =A0 =A0 TCP_FLAG_SYN =3D __cpu_to_be32(0x00020000),
>> - =A0 =A0 TCP_FLAG_FIN =3D __cpu_to_be32(0x00010000),
>> - =A0 =A0 TCP_RESERVED_BITS =3D __cpu_to_be32(0x0F000000),
>> - =A0 =A0 TCP_DATA_OFFSET =3D __cpu_to_be32(0xF0000000)
>> + =A0 =A0 TCP_FLAG_CWR =3D __constant_cpu_to_be32(0x00800000),
>> + =A0 =A0 TCP_FLAG_ECE =3D __constant_cpu_to_be32(0x00400000),
>> + =A0 =A0 TCP_FLAG_URG =3D __constant_cpu_to_be32(0x00200000),
>> + =A0 =A0 TCP_FLAG_ACK =3D __constant_cpu_to_be32(0x00100000),
>> + =A0 =A0 TCP_FLAG_PSH =3D __constant_cpu_to_be32(0x00080000),
>> + =A0 =A0 TCP_FLAG_RST =3D __constant_cpu_to_be32(0x00040000),
>> + =A0 =A0 TCP_FLAG_SYN =3D __constant_cpu_to_be32(0x00020000),
>> + =A0 =A0 TCP_FLAG_FIN =3D __constant_cpu_to_be32(0x00010000),
>> + =A0 =A0 TCP_RESERVED_BITS =3D __constant_cpu_to_be32(0x0F000000),
>> + =A0 =A0 TCP_DATA_OFFSET =3D __constant_cpu_to_be32(0xF0000000)
>> =A0};
>>
>> =A0/*
>>
>
> --
> Jiri Kosina
> SUSE Labs



--=20
Paul Pluzhnikov

--f46d044287bea8bb3804ba9c0b07
Content-Type: text/plain; charset=US-ASCII; name="linux-tcp_h-patch-20111229.txt"
Content-Disposition: attachment; filename="linux-tcp_h-patch-20111229.txt"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gzhm7aqn0

ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbGludXgvdGNwLmggYi9pbmNsdWRlL2xpbnV4L3RjcC5oCmlu
ZGV4IDdmNTllZTkuLjYzMzM0ZjcgMTAwNjQ0Ci0tLSBhL2luY2x1ZGUvbGludXgvdGNwLmgKKysr
IGIvaW5jbHVkZS9saW51eC90Y3AuaApAQCAtNjksMTYgKzY5LDE2IEBAIHVuaW9uIHRjcF93b3Jk
X2hkciB7CiAjZGVmaW5lIHRjcF9mbGFnX3dvcmQodHApICggKCh1bmlvbiB0Y3Bfd29yZF9oZHIg
KikodHApKS0+d29yZHMgWzNdKSAKIAogZW51bSB7IAotCVRDUF9GTEFHX0NXUiA9IF9fY3B1X3Rv
X2JlMzIoMHgwMDgwMDAwMCksCi0JVENQX0ZMQUdfRUNFID0gX19jcHVfdG9fYmUzMigweDAwNDAw
MDAwKSwKLQlUQ1BfRkxBR19VUkcgPSBfX2NwdV90b19iZTMyKDB4MDAyMDAwMDApLAotCVRDUF9G
TEFHX0FDSyA9IF9fY3B1X3RvX2JlMzIoMHgwMDEwMDAwMCksCi0JVENQX0ZMQUdfUFNIID0gX19j
cHVfdG9fYmUzMigweDAwMDgwMDAwKSwKLQlUQ1BfRkxBR19SU1QgPSBfX2NwdV90b19iZTMyKDB4
MDAwNDAwMDApLAotCVRDUF9GTEFHX1NZTiA9IF9fY3B1X3RvX2JlMzIoMHgwMDAyMDAwMCksCi0J
VENQX0ZMQUdfRklOID0gX19jcHVfdG9fYmUzMigweDAwMDEwMDAwKSwKLQlUQ1BfUkVTRVJWRURf
QklUUyA9IF9fY3B1X3RvX2JlMzIoMHgwRjAwMDAwMCksCi0JVENQX0RBVEFfT0ZGU0VUID0gX19j
cHVfdG9fYmUzMigweEYwMDAwMDAwKQorCVRDUF9GTEFHX0NXUiA9IF9fY29uc3RhbnRfY3B1X3Rv
X2JlMzIoMHgwMDgwMDAwMCksCisJVENQX0ZMQUdfRUNFID0gX19jb25zdGFudF9jcHVfdG9fYmUz
MigweDAwNDAwMDAwKSwKKwlUQ1BfRkxBR19VUkcgPSBfX2NvbnN0YW50X2NwdV90b19iZTMyKDB4
MDAyMDAwMDApLAorCVRDUF9GTEFHX0FDSyA9IF9fY29uc3RhbnRfY3B1X3RvX2JlMzIoMHgwMDEw
MDAwMCksCisJVENQX0ZMQUdfUFNIID0gX19jb25zdGFudF9jcHVfdG9fYmUzMigweDAwMDgwMDAw
KSwKKwlUQ1BfRkxBR19SU1QgPSBfX2NvbnN0YW50X2NwdV90b19iZTMyKDB4MDAwNDAwMDApLAor
CVRDUF9GTEFHX1NZTiA9IF9fY29uc3RhbnRfY3B1X3RvX2JlMzIoMHgwMDAyMDAwMCksCisJVENQ
X0ZMQUdfRklOID0gX19jb25zdGFudF9jcHVfdG9fYmUzMigweDAwMDEwMDAwKSwKKwlUQ1BfUkVT
RVJWRURfQklUUyA9IF9fY29uc3RhbnRfY3B1X3RvX2JlMzIoMHgwRjAwMDAwMCksCisJVENQX0RB
VEFfT0ZGU0VUID0gX19jb25zdGFudF9jcHVfdG9fYmUzMigweEYwMDAwMDAwKQogfTsgCiAKIC8q
Cg==
--f46d044287bea8bb3804ba9c0b07--
