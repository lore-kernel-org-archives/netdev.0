From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.34-git] 8139too: fix Coding Styles
Date: Thu, 15 Apr 2010 00:08:48 -0700 (PDT)
Message-ID: <20100415.000848.204966269.davem@davemloft.net>
References: <ba865f7b49c5df1b71bc393ad42ff40a.squirrel@neurowork.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: jblanco@neurowork.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39768
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752016Ab0DOHIn convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Apr 2010 03:08:43 -0400
In-Reply-To: <ba865f7b49c5df1b71bc393ad42ff40a.squirrel@neurowork.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Javier Blanco de Torres (Neurowork)" <jblanco@neurowork.net>
Date: Mon, 12 Apr 2010 09:36:43 +0200

> Fixed coding styles in the 8139too net driver.
>=20
> Signed-off-by: Javier Blanco de Torres <jblanco@neurowork.net>
> Signed-off-by: Alejandro S=E1nchez Acosta <asanchez@neurowork.net>

This is why I absolutely hate pure checkpatch.pl patches, people just
try to make the tool happy and don't think about what the tool is
trying to tell them.

The worst of this is this "typedef enum" part of your changes:

-typedef enum {
+enum {
 	RTL8139 =3D 0,
 	RTL8129,
 } board_t;

and checkpatch was telling you:

WARNING: do not add new typedefs
#220: FILE: net/8139too.c:220:
+typedef enum {

Well, you're still adding a new type!  Getting rid of the type name is
what it's telling you to stop doing.

It's still a newly named type after your change, it wants you to get
rid of the "board_t" thing altogether.

Give the enum a real "enum" name like:

enum rtl8139_board_t {

Then use _THAT_ in the sources:

	enum rtl8139_board_t x;

The typedef section of Documentation/CodingStyle makes this very
clear.

But your entire patch is like this, the changes are largely pointless
and many of them are false interpreations of what checkpatch complains
about.

Therefore I really don't encourage that you pursue this any further,
sorry.
