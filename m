From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] usbnet: Fix dma setup for fragmented packets that need
 a pad byte appended.
Date: Tue, 14 Jan 2014 06:41:58 -0800
Message-ID: <1389710518.31367.259.camel@edumazet-glaptop2.roam.corp.google.com>
References: <063D6719AE5E284EB5DD2968C1650D6D45B28F@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:56455 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751342AbaANOl5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 09:41:57 -0500
Received: by mail-pd0-f170.google.com with SMTP id z10so3538259pdj.1
        for <netdev@vger.kernel.org>; Tue, 14 Jan 2014 06:41:57 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D45B28F@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-01-14 at 11:16 +0000, David Laight wrote:
> If the usbnet code appends a byte to a fragmented packet (in order to=
 avoid
> sending a bulk data message that is a multiple of the USB message siz=
e) then
> the scatter-gather list isn't initialised correctly.
> This causes a later panic in usb_hcd_map_urb_for_dma().
> Basically when the code tries to access the final sg fragment the sg =
function
> returns NULL because the 'end of sg list' market is set in the previo=
us one.
>=20
> Bug introduced in commit 60e453a940ac678565b6641d65f8c18541bb9f28
> (USBNET: fix handling padding packet) and needs applying to all
> kernels that contain this change (including 3.12).
>=20
> Fix from Bjorn Mork.
>=20
> Signed-off-by: David Laight <david.laight@aculab.com>
> ---
>=20
> I think it is ok that the sg table's last element is never assigned t=
o when
> the packet isn't padded.

Original patch contained :

=46ixes: 60e453a940ac ("USBNET: fix handling padding packet")
Reported-by: Thomas Kear <thomas@kear.co.nz>
Cc: Ming Lei <ming.lei@canonical.com>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>

Why did you remove this and took ownership of this patch ?

It seems you would only need to either add :

Acked-by: ...

or=20

Tested-by: ...

or

Reviewed-by: ...
