From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] ifb: add multi-queue support
Date: Wed, 11 Nov 2009 17:56:59 +0800
Message-ID: <412e6f7f0911110156l350dbb8ewdb1d669c30555770@mail.gmail.com>
References: <4AFA8911.7050204@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=000e0cd2dff09b9a1b0478157272
Cc: Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:49838 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752536AbZKKJ4x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 04:56:53 -0500
Received: by pwi3 with SMTP id 3so593643pwi.21
        for <netdev@vger.kernel.org>; Wed, 11 Nov 2009 01:56:59 -0800 (PST)
In-Reply-To: <4AFA8911.7050204@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--000e0cd2dff09b9a1b0478157272
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: quoted-printable

2009/11/11 Changli Gao <xiaosuo@gmail.com>:
> ifb: add multi-queue support
>
> Add multi-queue support, and one kernel thread is created for per queue.
> It can used to emulate multi-queue NIC in software, and distribute work
> among CPUs.
> gentux linux # modprobe ifb numtxqs=3D2
> gentux linux # ifconfig ifb0 up
> gentux linux # pgrep ifb0
> 18508
> 18509
> gentux linux # taskset -p 1 18508
> pid 18508's current affinity mask: 3
> pid 18508's new affinity mask: 1
> gentux linux # taskset -p 2 18509
> pid 18509's current affinity mask: 3
> pid 18509's new affinity mask: 2
> gentux linux # tc qdisc add dev br0 ingress
> gentux linux # tc filter add dev br0 parent ffff: protocol ip basic
> action mirred egress redirect dev ifb0
>
> This patch also introduces a ip link option "numtxqs" for specifying the
> number of the TX queues. so you can add a new ifb with the command:
>
> ip link add numtxqs 4 type ifb
>

The corresponding patch for iproute2 is attached too. And you need to
update the linux header files too.


--=20
Regards=A3=AC
Changli Gao(xiaosuo@gmail.com)

--000e0cd2dff09b9a1b0478157272
Content-Type: application/octet-stream; name="iproute2-support-numtxqs.diff"
Content-Disposition: attachment; filename="iproute2-support-numtxqs.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_g1vx20xy0

LS0tIGlwL2lwbGluay5jLm9yaWcJMjAwOS0xMS0xMSAxNjo1Njo0MS4wMDAwMDAwMDAgKzA4MDAK
KysrIGlwL2lwbGluay5jCTIwMDktMTEtMTEgMTc6MzI6NTIuMDAwMDAwMDAwICswODAwCkBAIC00
OCw2ICs0OCw3IEBACiAJCWZwcmludGYoc3RkZXJyLCAiICAgICAgICAgICAgICAgICAgIFsgYWRk
cmVzcyBMTEFERFIgXVxuIik7CiAJCWZwcmludGYoc3RkZXJyLCAiICAgICAgICAgICAgICAgICAg
IFsgYnJvYWRjYXN0IExMQUREUiBdXG4iKTsKIAkJZnByaW50ZihzdGRlcnIsICIgICAgICAgICAg
ICAgICAgICAgWyBtdHUgTVRVIF1cbiIpOworCQlmcHJpbnRmKHN0ZGVyciwgIiAgICAgICAgICAg
ICAgICAgICBbIG51bXR4cXMgTlVNVFhRUyBdXG4iKTsKIAkJZnByaW50ZihzdGRlcnIsICIgICAg
ICAgICAgICAgICAgICAgdHlwZSBUWVBFIFsgQVJHUyBdXG4iKTsKIAkJZnByaW50ZihzdGRlcnIs
ICIgICAgICAgaXAgbGluayBkZWxldGUgREVWIHR5cGUgVFlQRSBbIEFSR1MgXVxuIik7CiAJCWZw
cmludGYoc3RkZXJyLCAiXG4iKTsKQEAgLTE4MCw2ICsxODEsNyBAQAogCWludCBxbGVuID0gLTE7
CiAJaW50IG10dSA9IC0xOwogCWludCBuZXRucyA9IC0xOworCWludCBudW10eHFzID0gLTE7CiAK
IAlyZXQgPSBhcmdjOwogCkBAIC0yMjEsNiArMjIzLDEzIEBACiAJCQlpZiAoZ2V0X2ludGVnZXIo
Jm10dSwgKmFyZ3YsIDApKQogCQkJCWludmFyZygiSW52YWxpZCBcIm10dVwiIHZhbHVlXG4iLCAq
YXJndik7CiAJCQlhZGRhdHRyX2woJnJlcS0+biwgc2l6ZW9mKCpyZXEpLCBJRkxBX01UVSwgJm10
dSwgNCk7CisJCX0gZWxzZSBpZiAoc3RyY21wKCphcmd2LCAibnVtdHhxcyIpID09IDApIHsKKwkJ
CU5FWFRfQVJHKCk7CisJCQlpZiAobnVtdHhxcyAhPSAtMSkKKwkJCQlkdXBhcmcoIm51bXR4cXMi
LCAqYXJndik7CisJCQlpZiAoZ2V0X2ludGVnZXIoJm51bXR4cXMsICphcmd2LCAwKSkKKwkJCQlp
bnZhcmcoIkludmFsaWQgXCJudW10eHFzXCIgdmFsdWVcbiIsICphcmd2KTsKKwkJCWFkZGF0dHJf
bCgmcmVxLT5uLCBzaXplb2YoKnJlcSksIElGTEFfTlRYUSwgJm51bXR4cXMsIDIpOwogICAgICAg
ICAgICAgICAgIH0gZWxzZSBpZiAoc3RyY21wKCphcmd2LCAibmV0bnMiKSA9PSAwKSB7CiAgICAg
ICAgICAgICAgICAgICAgICAgICBORVhUX0FSRygpOwogICAgICAgICAgICAgICAgICAgICAgICAg
aWYgKG5ldG5zICE9IC0xKQo=
--000e0cd2dff09b9a1b0478157272--
