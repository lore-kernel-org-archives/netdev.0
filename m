From: David Strand <dpstrand@gmail.com>
Subject: Re: [PATCH] bonding: check for assigned mac before adopting the
 slaves mac address
Date: Wed, 24 Nov 2010 17:45:42 -0800
Message-ID: <AANLkTi=-DzUmopboX13V_cd=mZnmD=mBNNCuhQYF0PQQ@mail.gmail.com>
References: <AANLkTinpO=FmoecfV8epubXU4OrhFsXJ7-Kc68yNhMEs@mail.gmail.com>
	<31169.1290641617@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:49729 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752555Ab0KYBpn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Nov 2010 20:45:43 -0500
In-Reply-To: <31169.1290641617@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have a use case where we assign a mac to the bond device, because
the slave device configuration may change periodically. With older
kernels, it honored the assigned mac and everything was fine, with
2.6.36 it now uses the mac of whatever slave device is first instead
of our assigned one.

ifenslave code and documentation appears to still support the old way,
where a bond assigned mac will reign supreme, so this patch restores
that behavior.

On Wed, Nov 24, 2010 at 3:33 PM, Jay Vosburgh <fubar@us.ibm.com> wrote:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0How exactly is this a regression? =C2=A0Th=
e above referenced patch
> changes the method used to decide if the bonding master needs to have
> it's MAC address set. =C2=A0The original way was "bonding master's MA=
C is
> zero," after the above, it's "adding first slave."
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Do you have some use case that manually se=
ts the master's MAC
> address prior to adding any slaves?
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0-J
