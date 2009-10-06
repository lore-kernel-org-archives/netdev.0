From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next-2.6 PATCH 8/9] vxge: Acquire correct lock based on
 interrupt context.
Date: Tue, 06 Oct 2009 05:19:06 +0200
Message-ID: <4ACAB72A.3080802@gmail.com>
References: <Pine.GSO.4.10.10910050757300.9377-100000@guinness> <20091005.053759.74765905.davem@davemloft.net> <78C9135A3D2ECE4B8162EBDCE82CAD7705C16322@nekter>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>,
	netdev@vger.kernel.org
To: Ramkrishna Vepa <Ramkrishna.Vepa@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:57749 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756088AbZJFDUN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 23:20:13 -0400
In-Reply-To: <78C9135A3D2ECE4B8162EBDCE82CAD7705C16322@nekter>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ramkrishna Vepa a =E9crit :
> [Ram] Right, but why have the additional step of saving and restoring
> the flags while in the interrupt context?
>=20

It costs about the same thing than testing two times in_interrupt()

pushf
pop register
test iflag,register
je ...


In the end, original code is shorter and faster.
