From: Li Yu <raise.sail@gmail.com>
Subject: Re: [PATCH] tcp: remove useless update for flag parameter in tcp_enter_frto_loss()
Date: Wed, 28 Mar 2012 14:54:01 +0800
Message-ID: <4F72B589.5060903@gmail.com>
References: <4F729235.8040706@gmail.com> <CADVnQymQaCSKx0aRda6OiP=t2OToxHmvjXjYvTdxsq7oFE3DTg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:57859 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751143Ab2C1GyK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2012 02:54:10 -0400
Received: by iagz16 with SMTP id z16so1070649iag.19
        for <netdev@vger.kernel.org>; Tue, 27 Mar 2012 23:54:10 -0700 (PDT)
In-Reply-To: <CADVnQymQaCSKx0aRda6OiP=t2OToxHmvjXjYvTdxsq7oFE3DTg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012=E5=B9=B403=E6=9C=8828=E6=97=A5 13:29, Neal Cardwell =E5=86=
=99=E9=81=93:
> On Wed, Mar 28, 2012 at 12:23 AM, Li Yu<raise.sail@gmail.com>  wrote:
>>
>> It seem that we forget remove below two lines after copying code :)
>>
>> This update never impacts others.
>
> The 'flag' variable will be used in later iterations of the
> tcp_for_write_queue() loop. The comment seems to quite sensibly
> indicate that the FLAG_DATA_ACKED bit is being set to avoid entering
> that branch of the if statement in later segments in the loop:
>
> 2168                 if ((tp->frto_counter =3D=3D 1)&&  !(flag&  FLAG=
_DATA_ACKED)) {
> 2169                         /* For some reason this R-bit might get =
cleared? */
> 2170                         if (TCP_SKB_CB(skb)->sacked&  TCPCB_SACK=
ED_RETRANS)
> 2171                                 tp->retrans_out +=3D tcp_skb_pco=
unt(skb);
> 2172                         /* ...enter this if branch just for the
> first segment */
> 2173                         flag |=3D FLAG_DATA_ACKED;
> 2174                 } else {
>
> The structure of the logic seems intact from the original commit that
> added this:
>
> http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux.git;a=3Dco=
mmitdiff;h=3Dd1a54c6a0a3f9c2c4ef71982d89b8571bd9eaa51
>

Sorry for spent time on this, it it account for F-RTO retransmitted
segment here.

Yu

> neal
>
