From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net] sock, diag: fix panic in sock_diag_put_filterinfo
Date: Wed, 2 Sep 2015 15:10:48 +0200
Message-ID: <55E6F558.9090500@6wind.com>
References: <8824dd0b0b627c5dfdfd767e0e366e3cc8f9505a.1441193159.git.daniel@iogearbox.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ast@plumgrid.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:35792 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753286AbbIBNKv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 09:10:51 -0400
Received: by wicge5 with SMTP id ge5so40408896wic.0
        for <netdev@vger.kernel.org>; Wed, 02 Sep 2015 06:10:50 -0700 (PDT)
In-Reply-To: <8824dd0b0b627c5dfdfd767e0e366e3cc8f9505a.1441193159.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 02/09/2015 14:00, Daniel Borkmann a =C3=A9crit :
> diag socket's sock_diag_put_filterinfo() dumps classic BPF programs
> upon request to user space (ss -0 -b). However, native eBPF programs
> attached to sockets (SO_ATTACH_BPF) cannot be dumped with this method=
:
>
> Their orig_prog is always NULL. However, sock_diag_put_filterinfo()
> unconditionally tries to access its filter length resp. wants to copy
> the filter insns from there. Internal cBPF to eBPF transformations
> attached to sockets don't have this issue, as orig_prog state is kept=
=2E
>
> It's currently only used by packet sockets. If we would want to add
> native eBPF support in the future, this needs to be done through
> a different attribute than PACKET_DIAG_FILTER to not confuse possible
> user space disassemblers that work on diag data.
>
> Fixes: 89aa075832b0 ("net: sock: allow eBPF programs to be attached t=
o sockets")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
