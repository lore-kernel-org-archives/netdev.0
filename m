From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next V2] net: introduce ethernet teaming device
Date: Sun, 23 Oct 2011 17:50:53 +0200
Message-ID: <20111023155051.GA2141@minipsycho.redhat.com>
References: <1319200747-2508-1-git-send-email-jpirko@redhat.com>
 <1319208237.32161.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20111022151346.GA2028@minipsycho.orion>
 <1319302282.6180.60.camel@edumazet-laptop>
 <20111023082545.GA15908@minipsycho.orion>
 <1319366709.27507.14.camel@edumazet-laptop>
 <20111023125101.GA20078@minipsycho.orion>
 <1319380668.27507.19.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	bhutchings@solarflare.com, shemminger@vyatta.com, fubar@us.ibm.com,
	andy@greyhouse.net, tgraf@infradead.org, ebiederm@xmission.com,
	mirqus@gmail.com, kaber@trash.net, greearb@candelatech.com,
	jesse@nicira.com, fbl@redhat.com, benjamin.poirier@gmail.com,
	jzupka@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11055 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751538Ab1JWPvY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Oct 2011 11:51:24 -0400
Content-Disposition: inline
In-Reply-To: <1319380668.27507.19.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Oct 23, 2011 at 04:37:48PM CEST, eric.dumazet@gmail.com wrote:
>Le dimanche 23 octobre 2011 =E0 14:51 +0200, Jiri Pirko a =E9crit :
>
>> Yes. And team->mode_ops.receive can change only after synchronize_rc=
u is
>> done. It's not possible it changes within the window you are talking=
 about.
>
>If it was true, you would not need the synchronize_rcu() call you adde=
d
>in __team_change_mode() :
>
>
>----------------------------------------------------------------------
>
>static int __team_change_mode(struct team *team,
>                             const struct team_mode *new_mode)
>{
>       /* Check if mode was previously set and do cleanup if so */
>       if (team->mode_kind) {
>               void (*exit_op)(struct team *team) =3D team->mode_ops.e=
xit;
>
>               /* Clear ops area so no callback is called any longer *=
/
>               team_mode_ops_clear(&team->mode_ops);
>
>               synchronize_rcu();
>
>               if (exit_op)
>                       exit_op(team);
>
>
>----------------------------------------------------------------------=
-
>
>So the question is : Why do you have this synchronize_rcu() call here =
?

You are right. This call is redundant here. I'll remove it.
This also means I can use memset & memcpy for mode_ops after all.

I'll change that and add comment about this locking situation to avoid
confusion.

Thanks a lot Eric!

Jirka

>
>
>
