From: krbmit siso <krbmit@gmail.com>
Subject: Re: protect raw sockets
Date: Thu, 18 Aug 2011 13:58:58 +0530
Message-ID: <CABjs8yWMgyyPHC1Nfgs2TZ1ixN7Khq0OimEhUhTs-Ux_9LAx5g@mail.gmail.com>
References: <A2354B6A9F807641B21EEABD666ECEEA011AFCE2@XMB-BGL-416.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org, ipsec-tools-users@lists.sourceforge.net,
	ipsec-tools-devel@lists.sourceforge.net,
	ikev2-devel@lists.sourceforge.net,
	=?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:45954 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752081Ab1HRI27 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2011 04:28:59 -0400
Received: by ywf7 with SMTP id 7so1313196ywf.19
        for <netdev@vger.kernel.org>; Thu, 18 Aug 2011 01:28:58 -0700 (PDT)
In-Reply-To: <A2354B6A9F807641B21EEABD666ECEEA011AFCE2@XMB-BGL-416.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Timo,

Thanks for your reply .
Yes i did explore this yesterday and i was successful in sending the IK=
E
messages unprotected after using the below code only for UDP sockets.

int setsockopt_bypass(int fd, int family)
{
        struct sadb_x_policy policy;
        int level, optname;

        switch (family) {
                case AF_INET:
                        level =3D IPPROTO_IP;
                        optname =3D IP_IPSEC_POLICY;
                        break;
                case AF_INET6:
                        level =3D IPPROTO_IPV6;
                        optname =3D IPV6_IPSEC_POLICY;
                        break;
                default:
                        return -1;
        }

        memset(&policy, 0, sizeof(policy));
        policy.sadb_x_policy_len =3D PFKEY_UNIT64(sizeof(policy));
        policy.sadb_x_policy_exttype =3D SADB_X_EXT_POLICY;
        policy.sadb_x_policy_type =3D IPSEC_POLICY_BYPASS;
        policy.sadb_x_policy_dir =3D IPSEC_DIR_INBOUND;
        if (setsockopt(fd, level, optname, &policy, sizeof(policy)) =3D=
=3D -1) {
                return -1;
        }
        policy.sadb_x_policy_dir =3D IPSEC_DIR_OUTBOUND;
        if (setsockopt(fd, level, optname, &policy, sizeof(policy)) =3D=
=3D -1) {
                return -1;
        }
        return 0;
}

But i did try the same on RAW socket by setting the policy has
policy.sadb_x_policy_type =3D IPSEC_POLICY_ENTRUST|IPSEC_POLICY_IPSEC;
But the packet is going unprotected .
Please show some light on how to protect RAW packets if there is a Poli=
cy
matching in the SPD saying it need to be protected.
I have checked the posting there is no help on this isues , could
you please give some options , if it is possible from Application.


Thanks and Regards
Naveen

On Thu, Aug 18, 2011 at 1:45 PM, Naveen B N (nbn) <nbn@cisco.com> wrote=
:
> Hi All,
> Is there a way to enforce IPsec protection for packets sent from
> application using RAW_SOCKET.
>
> My analysis is to add a code at the raw_sendmsg() & raw_v4_input() to
> call xfrm_policy_check() ..
> Is it a good method to proceed or is there a better and smart way to
> achieve this .
>
> Hoping for some guide lines ..
>
> Thanks in advance ..
>
> Thanks and Regards
> Naveen
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
