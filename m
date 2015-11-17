From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] xen-netfront crash when detaching network while some
 network activity
Date: Tue, 17 Nov 2015 11:59:17 +0000
Message-ID: <564B1695.8000009@citrix.com>
References: <20150522114932.GC8664@mail-itl> <55645140.1050209@citrix.com>
	<20150526220312.GA1358@mail-itl> <20151021185734.GD31646@mail-itl>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	xen-devel <xen-devel@lists.xen.org>,
	Annie Li <annie.li@oracle.com>
To: =?windows-1252?Q?Marek_Marczykowski-G=F3recki?=
	<marmarek@invisiblethingslab.com>,
	David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:5493 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751202AbbKQL7W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Nov 2015 06:59:22 -0500
In-Reply-To: <20151021185734.GD31646@mail-itl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21/10/15 19:57, Marek Marczykowski-G=F3recki wrote:
>=20
> Any ideas?

No, sorry.  Netfront looks correct to me.

We take an additional ref for the ref released by
gnttab_release_grant_reference().  The get_page() here is safe since we
haven't freed the page yet (this is done in the subsequent call to
skb_kfree_irq()).

get_page()/put_page() also look fine when used with tail pages.

David
