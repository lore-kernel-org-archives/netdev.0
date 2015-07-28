From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC PATCH v4 net-next 1/4] tcp: replace cnt & rtt with struct
 in pkts_acked()
Date: Mon, 27 Jul 2015 20:42:37 -0700
Message-ID: <20150728034236.GA38906@Alexeis-MBP.westell.com>
References: <1437792426-1724090-1-git-send-email-brakmo@fb.com>
 <1437792426-1724090-2-git-send-email-brakmo@fb.com>
 <20150727114601.42fc6b63@urahara>
 <D1DBD200.6038%brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>,
	Kernel Team <Kernel-team@fb.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Yuchung Cheng <ycheng@google.com>
To: Lawrence Brakmo <brakmo@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:36050 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753934AbbG1Dmm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 23:42:42 -0400
Received: by pdjr16 with SMTP id r16so63976732pdj.3
        for <netdev@vger.kernel.org>; Mon, 27 Jul 2015 20:42:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <D1DBD200.6038%brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 27, 2015 at 07:30:39PM +0000, Lawrence Brakmo wrote:
>=20
>=20
> I prefer the cleanliness of passing a structure and don=B9t think the
> overhead will be significant enough to worry about it.
> Will the compiler pass struct values in registers if the struct is
> passed by value?

In passing struct by value it's not a matter of optimization but C abi.
On sparc even 4-byte structs are passed by reference which creates
an extra copy of the same struct on stack.
Struct returns are even worse. I would always pass structs by reference
in C. C++ is different matter.
