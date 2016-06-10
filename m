From: Sven Eckelmann <sven@narfation.org>
Subject: Re: [PATCH next] sched: remove NET_XMIT_POLICED
Date: Fri, 10 Jun 2016 18:30:23 +0200
Message-ID: <4871472.EuzojNRMXg@bentobox>
References: <1465561289-15401-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart7404349.2YmCx67clr"; micalg="pgp-sha512"; protocol="application/pgp-signature"
Cc: netdev@vger.kernel.org, a@unstable.cc, sw@simonwunderlich.de,
	mareklindner@neomailbox.ch
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:47338 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933373AbcFJQab (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jun 2016 12:30:31 -0400
In-Reply-To: <1465561289-15401-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart7404349.2YmCx67clr
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

On Friday 10 June 2016 14:21:29 Florian Westphal wrote:
[...]
> BATMAN uses it as an intermediate return value to signal
> forwarding vs. buffering, but it will not return POLICED to
> callers outside of BATMAN.
[...]
> diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
> index f2f1256..b1a4e8a 100644
> --- a/net/batman-adv/send.c
> +++ b/net/batman-adv/send.c
> @@ -156,7 +156,7 @@ int batadv_send_unicast_skb(struct sk_buff *skb,
>   * attempted.
>   *
>   * Return: NET_XMIT_SUCCESS on success, NET_XMIT_DROP on failure, or
> - * NET_XMIT_POLICED if the skb is buffered for later transmit.
> + * -EINPROGRESS if the skb is buffered for later transmit.
>   */
>  int batadv_send_skb_to_orig(struct sk_buff *skb,
>  			    struct batadv_orig_node *orig_node,
> @@ -188,7 +188,7 @@ int batadv_send_skb_to_orig(struct sk_buff *skb,
>  	 * network coding fails, then send the packet as usual.
>  	 */
>  	if (recv_if && batadv_nc_skb_forward(skb, neigh_node)) {
> -		ret = NET_XMIT_POLICED;
> +		ret = -EINPROGRESS;
>  	} else {
>  		batadv_send_unicast_skb(skb, neigh_node);
>  		ret = NET_XMIT_SUCCESS;

Looks good to me. But it has a minor conflict with a queued up patch
for David (not yet submitted by Antonio). This is not real problem for
you but it looks like there is something wrong with the queued up patch.
I have submitted a fix for it and Antonio should just know that it is
related to this one.

But to your patch:

Reviewed-by: Sven Eckelmann <sven@narfation.org>

Kind regards,
	Sven

--nextPart7404349.2YmCx67clr
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXWusfAAoJEF2HCgfBJntGKosQAJx1IiBg7vUxSGr8vuwdX0du
timv/cl+f99CJdyUwm1abFTV0Xk3wWlPPWg4sAMjesiYFIXHho320kMGT9bXJq+F
6i/UJQPJ3occRnClyHOplOoFHAqNU8K7XnRCdo7I8JJIQL527uvjKQez/+1MhAif
npEDbrZ5uqIlT52ui6qaSsPs8wql3zFKCEadwlYxE3ItRC6F+AID0gPsVEuCvIhW
dsIB8EnxFRAgQHzKeD+mbzsEYPBYzVvSREjpzayRAEwjrFccxDYYkFYzadxoERxL
Q1zwUJlyPGsUb+v9JAR4wYp7TT0NJIE9E7Ye44gusq4GRMJOknHGVUSUiNoh2VeX
NjDAVPqdjIe7elJJJdtaPDbJdWNFiZTQGQCsqMIsRCwo1pfLiPpN+MLBomi55K3j
4QJdKXp17CMN6w8XM26SLIMb9VvnziSrs6FcRpnksAHhY5p4h1UiaQcpFI1SaRtF
2YUXiMU4Io47tPPh6ZE2ml6+px/ZrykIWLf4L3k0jmk9no5KTKmV78zOl2y9ZA8J
1JslEVU5amlxE1WLEjwN+kSBUuKhuUSaK9xUAxdBLu97dWPexwZhqYLzDqgvZQRA
QEgbp9uHipuEMR6EYa44GMaRNzc7gq2Lx7R9Hvlqd8J7rT3cy4m5MscinXY2ETOu
YcURH7MC2T07eA05Wca6
=2G8O
-----END PGP SIGNATURE-----

--nextPart7404349.2YmCx67clr--
