From: Kumar SANGHVI <kumar.sanghvi@stericsson.com>
Subject: Re: [PATCH 3/4] Phonet: cleanup pipe enable socket option
Date: Mon, 11 Oct 2010 12:20:28 +0530
Message-ID: <20101011065027.GB31124@bnru01.bnr.st.com>
References: <1286546523-3340-1-git-send-email-remi@remlab.net>
 <1286546523-3340-2-git-send-email-remi@remlab.net>
 <1286546523-3340-3-git-send-email-remi@remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	=?iso-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>
To: =?iso-8859-1?Q?R=E9mi?= Denis-Courmont <remi@remlab.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:48239 "EHLO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752809Ab0JKGui (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Oct 2010 02:50:38 -0400
Content-Disposition: inline
In-Reply-To: <1286546523-3340-3-git-send-email-remi@remlab.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri, Oct 08, 2010 at 16:02:02 +0200, R=E9mi Denis-Courmont wrote:
> From: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
>=20
> The current code works like this:
>=20
>   int garbage, status;
>   socklen_t len =3D sizeof(status);
>=20
>   /* enable pipe */
>   setsockopt(fd, SOL_PNPIPE, PNPIPE_ENABLE, &garbage, sizeof(garbage)=
);
>   /* disable pipe */
>   setsockopt(fd, SOL_PNPIPE, PNPIPE_DISABLE, &garbage, sizeof(garbage=
));
>   /* get status */
>   getsockopt(fd, SOL_PNPIPE, PNPIPE_INQ, &status, &len);
>=20
> ...which does not follow the usual socket option pattern. This patch
> merges all three "options" into a single gettable&settable option,
> before Linux 2.6.37 gets out:
>=20
>   int status;
>   socklen_t len =3D sizeof(status);
>=20
>   /* enable pipe */
>   status =3D 1;
>   setsockopt(fd, SOL_PNPIPE, PNPIPE_ENABLE, &status, sizeof(status));
>   /* disable pipe */
>   status =3D 0;
>   setsockopt(fd, SOL_PNPIPE, PNPIPE_ENABLE, &status, sizeof(status));
>   /* get status */
>   getsockopt(fd, SOL_PNPIPE, PNPIPE_ENABLE, &status, &len);
>=20
> This also fixes the error code from EFAULT to ENOTCONN.
>=20
> Signed-off-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
> Cc: Kumar Sanghvi <kumar.sanghvi@stericsson.com>
=20
Thank you!

BR,
Kumar.
