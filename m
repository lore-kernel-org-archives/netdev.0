From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Add JMEMCMP to Berkeley Packet Filters
Date: Thu, 10 Feb 2011 14:24:52 +0100
Message-ID: <1297344292.2493.3.camel@edumazet-laptop>
References: <1297341067-12264-1-git-send-email-ian.molton@collabora.co.uk>
	 <1297341067-12264-2-git-send-email-ian.molton@collabora.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, rdunlap@xenotime.net, isdn@linux-pingi.de,
	paulus@samba.org, arnd@arndb.de, davem@davemloft.net,
	herbert@gondor.apana.org.au, ebiederm@xmission.com,
	alban.crequy@collabora.co.uk
To: Ian Molton <ian.molton@collabora.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:55897 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751162Ab1BJNZs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Feb 2011 08:25:48 -0500
Received: by fxm20 with SMTP id 20so1470488fxm.19
        for <netdev@vger.kernel.org>; Thu, 10 Feb 2011 05:25:47 -0800 (PST)
In-Reply-To: <1297341067-12264-2-git-send-email-ian.molton@collabora.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 10 f=C3=A9vrier 2011 =C3=A0 12:31 +0000, Ian Molton a =C3=A9cr=
it :
> This patch allows a data section to be specified for BPF.
>=20
> This is made use of by a MEMCMP like instruction.
>=20
> Testsuite here:
> http://git.collabora.co.uk/?p=3Duser/ian/check-bpf.git;a=3Dsummary
>=20
> Issues:
> * Do I need to update the headers for all arches, or just generic
> * Can sk_run_filter() be called in a context where kmalloc(GFP_KERNEL=
) is
>   not allowed (I think not)

You cannot use GFP_KERNEL in sk_run_filter() : We run in {soft}irq mode=
,
in input path.

> * Data section allocated with second call to sock_kmalloc().
> * Should the patch be broken into two - one to add the data uploading=
,
>   one to add the JMEMCMP insn. ?

May I ask why it is needed at all ?

Then, why only one JMEMCMP would be allowed in a filter ?



