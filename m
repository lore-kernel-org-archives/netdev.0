From: Renato Westphal <renatowestphal@gmail.com>
Subject: Re: Move interface across network namespaces
Date: Fri, 19 Aug 2011 11:38:33 -0300
Message-ID: <CAChaegnHchLT0BV-_RaPT2-J3ZLin_U1x8X0KBi7ku1MArug1g@mail.gmail.com>
References: <CAChaegkomwjL0X7HnfLi1XH26jDKOL6fCgjfms67cjjU4gRXPg@mail.gmail.com>
	<m1r54s8lq4.fsf@fess.ebiederm.org>
	<CAChaegm2d3LywMAcq66PgPZwF5Fu=_zuqcTh8VdCG6zvhyPJXQ@mail.gmail.com>
	<CAChaeg=1WSU0webhYDpQcnq3cJje17FQ5Z8rypD8sdkyzcLT-g@mail.gmail.com>
	<m14o1e71qe.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kaber@trash.net,
	David Lamparter <equinox@diac24.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:48214 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752590Ab1HSOif convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2011 10:38:35 -0400
Received: by vws1 with SMTP id 1so2436465vws.19
        for <netdev@vger.kernel.org>; Fri, 19 Aug 2011 07:38:33 -0700 (PDT)
In-Reply-To: <m14o1e71qe.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> Well, this regression was introduced by commit a2835763e130c343ac,
>> which was merged into v2.6.34. Reverting parts of this commit makes
>> the problem go away but breaks the support of "specifying device fla=
gs
>> during device creation". I don't know the best way to fix this... an=
y
>> ideas?
>
> Everything going through dev_change_net_namespace already needs to be
> in the initialized state. =A0So it looks like we just need to do:
>
> Does the patch below work for you?
>
> Eric
>
> ---
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 17d67b5..bfbde69 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -6108,6 +6108,8 @@ int dev_change_net_namespace(struct net_device =
*dev, struct net *net, const char
> =A0 =A0 =A0 =A0call_netdevice_notifiers(NETDEV_UNREGISTER, dev);
> =A0 =A0 =A0 =A0call_netdevice_notifiers(NETDEV_UNREGISTER_BATCH, dev)=
;
>
> + =A0 =A0 =A0 rtmsg_ifinfo(RTM_DELLINK, dev, ~0U);
> +
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * =A0 =A0 =A0Flush the unicast and multicast chains
> =A0 =A0 =A0 =A0 */
>

 This works pretty fine. Thanks! :)

--=20
Renato Westphal
