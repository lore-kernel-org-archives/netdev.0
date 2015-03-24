From: Fan Du <fengyuleidian0615@gmail.com>
Subject: Re: tcp_v4_err/request sock refcnt leak?
Date: Tue, 24 Mar 2015 09:49:41 +0800
Message-ID: <5510C2B5.2030609@gmail.com>
References: <20150323090317.GB8934@haze> <550FEA98.3040009@gmail.com> <1427119917.25985.66.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Erik Hugne <erik.hugne@ericsson.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:34780 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752160AbbCXBzM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 21:55:12 -0400
Received: by pdbni2 with SMTP id ni2so205368648pdb.1
        for <netdev@vger.kernel.org>; Mon, 23 Mar 2015 18:55:11 -0700 (PDT)
In-Reply-To: <1427119917.25985.66.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2015=E5=B9=B403=E6=9C=8823=E6=97=A5 22:11, Eric Dumazet =E5=86=
=99=E9=81=93:
>> I'm not familiar with this part, IMHO, this might be a double call f=
or reqsk_put?
> It is yes.
>
> I got confused because reqsk_timer_handler()_has_  to call
> reqsk_put(req) after calling inet_csk_reqsk_queue_drop(), because
> the timer holds a reference on req.
>
> Would you like to send the official patch, mentioning :
>
> Fixes: fa76ce7328b2 ("inet: get rid of central tcp/dccp listener time=
r")

Looks like I've over slept last night.
Thanks Eric for cooking the patch 8)

--=20
=E5=A4=A9=E4=B8=8B=E8=8B=B1=E9=9B=84=E5=87=BA=E6=88=91=E8=BE=88=EF=BC=8C=
=E4=B8=80=E5=85=A5=E6=B1=9F=E6=B9=96=E5=B2=81=E6=9C=88=E5=82=AC=E3=80=82
=E9=B8=BF=E5=9B=BE=E9=9C=B8=E4=B8=9A=E8=B0=88=E7=AC=91=E9=97=B4=EF=BC=8C=
=E4=B8=8D=E8=83=9C=E4=BA=BA=E7=94=9F=E4=B8=80=E5=9C=BA=E9=86=89=E3=80=82
