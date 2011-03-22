From: Eugene Teo <eugeneteo@kernel.org>
Subject: Re: [Security] [SECURITY] DECnet: need to validate user data and
 access data?
Date: Tue, 22 Mar 2011 15:42:22 +0800
Message-ID: <AANLkTinbj295sZvXrQm6uhH9+DbAbY1AZU7Eo5_dC6HP@mail.gmail.com>
References: <1300750901.1813.15.camel@dan>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, security@kernel.org,
	linux-decnet-user@lists.sourceforge.net
To: Dan Rosenberg <drosenberg@vsecurity.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:58166 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754456Ab1CVHmX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2011 03:42:23 -0400
Received: by wya21 with SMTP id 21so6450199wya.19
        for <netdev@vger.kernel.org>; Tue, 22 Mar 2011 00:42:22 -0700 (PDT)
In-Reply-To: <1300750901.1813.15.camel@dan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc'ed the decnet list. Looks like it's still active even though the
status is orphan.

On Tue, Mar 22, 2011 at 7:41 AM, Dan Rosenberg <drosenberg@vsecurity.co=
m> wrote:
> In net/decnet/af_decnet.c, in the dn_access_copy() and dn_user_copy()
> functions, which are called from dn_connect(), length values are
> retrieved from incoming skb data and used as size values to copy
> functions:
>
> static void dn_access_copy(struct sk_buff *skb, struct accessdata_dn =
*acc)
> {
> =A0 =A0 =A0 =A0unsigned char *ptr =3D skb->data;
>
> =A0 =A0 =A0 =A0acc->acc_userl =3D *ptr++;
> =A0 =A0 =A0 =A0memcpy(&acc->acc_user, ptr, acc->acc_userl);
> =A0 =A0 =A0 =A0ptr +=3D acc->acc_userl;
>
> =A0 =A0 =A0 =A0acc->acc_passl =3D *ptr++;
> =A0 =A0 =A0 =A0memcpy(&acc->acc_pass, ptr, acc->acc_passl);
> =A0 =A0 =A0 =A0ptr +=3D acc->acc_passl;
>
> =A0 =A0 =A0 =A0acc->acc_accl =3D *ptr++;
> =A0 =A0 =A0 =A0memcpy(&acc->acc_acc, ptr, acc->acc_accl);
>
> =A0 =A0 =A0 =A0skb_pull(skb, acc->acc_accl + acc->acc_passl + acc->ac=
c_userl + 3);
>
> }
>
> static void dn_user_copy(struct sk_buff *skb, struct optdata_dn *opt)
> {
> =A0 =A0 =A0 =A0unsigned char *ptr =3D skb->data;
> =A0 =A0 =A0 =A0u16 len =3D *ptr++; /* yes, it's 8bit on the wire */
>
> =A0 =A0 =A0 =A0BUG_ON(len > 16); /* we've checked the contents earlie=
r */
> =A0 =A0 =A0 =A0opt->opt_optl =A0 =3D cpu_to_le16(len);
> =A0 =A0 =A0 =A0opt->opt_status =3D 0;
> =A0 =A0 =A0 =A0memcpy(opt->opt_data, ptr, len);
> =A0 =A0 =A0 =A0skb_pull(skb, len + 1);
> }
>
>
> Despite the BUG_ON and comment suggesting these lengths have been
> validated, I don't think this is actually the case - it looks like th=
ese
> fields are validated for outbound data, but I see no validation for
> inbound data (unless I'm mistaken, which is entirely possible). =A0If=
 this
> is the case, this can allow remote attackers to cause controllable he=
ap
> corruption. =A0I'd appreciate it if someone who knows this protocol b=
etter
> than I do took a look at this and implemented appropriate error handl=
ing
> if it needs it.
