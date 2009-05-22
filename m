From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: [RFC 2/2] net: Allow protocols to provide an unlocked_recvmsg sk_prot method
Date: Fri, 22 May 2009 10:26:51 +0300
Message-ID: <200905221026.51789.remi.denis-courmont@nokia.com>
References: <20090520230659.GC5956@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Chris Van Hoof <vanhoof@redhat.com>,
	Clark Williams <williams@redhat.com>
To: ext Arnaldo Carvalho de Melo <acme@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.105.134]:53105 "EHLO
	mgw-mx09.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752233AbZEVH03 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2009 03:26:29 -0400
In-Reply-To: <20090520230659.GC5956@ghostprotocols.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 21 May 2009 02:06:59 ext Arnaldo Carvalho de Melo wrote:
> So that the socket layer kwows which protocol uses locking and can as=
k
> for an unlocked recvmsg call inside recvmmsg, that takes the lock for=
 a
> batch of packets.
>
> Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
> ---
>  include/linux/socket.h |    3 ++
>  include/net/sock.h     |    5 ++++
>  net/core/sock.c        |   11 +++++++--
>  net/ipv4/udp.c         |   52
> ++++++++++++++++++++++++++++++++++++++++------- net/socket.c         =
  | =20
> 39 ++++++++++++++++++++++++----------- 5 files changed, 87 insertions=
(+),
> 23 deletions(-)
>
> diff --git a/include/linux/socket.h b/include/linux/socket.h
> index 50c6c44..7ef30a3 100644
> --- a/include/linux/socket.h
> +++ b/include/linux/socket.h
> @@ -265,6 +265,9 @@ struct ucred {
>  #define MSG_ERRQUEUE	0x2000	/* Fetch message from error queue */
>  #define MSG_NOSIGNAL	0x4000	/* Do not generate SIGPIPE */
>  #define MSG_MORE	0x8000	/* Sender will send more */
> +#ifdef __KERNEL__
> +#define MSG_UNLOCKED	0x10000	/* Don't lock the sock */
> +#endif

I might be missing something but... What prevents an evil userland from=
=20
setting the flag anyway and hitting the BUG case?

--=20
R=E9mi Denis-Courmont
Nokia Devices R&D, Maemo Software, Helsinki

