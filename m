From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next V2] net: introduce ethernet teaming device
Date: Sun, 23 Oct 2011 16:37:48 +0200
Message-ID: <1319380668.27507.19.camel@edumazet-laptop>
References: <1319200747-2508-1-git-send-email-jpirko@redhat.com>
	 <1319208237.32161.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111022151346.GA2028@minipsycho.orion>
	 <1319302282.6180.60.camel@edumazet-laptop>
	 <20111023082545.GA15908@minipsycho.orion>
	 <1319366709.27507.14.camel@edumazet-laptop>
	 <20111023125101.GA20078@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	bhutchings@solarflare.com, shemminger@vyatta.com, fubar@us.ibm.com,
	andy@greyhouse.net, tgraf@infradead.org, ebiederm@xmission.com,
	mirqus@gmail.com, kaber@trash.net, greearb@candelatech.com,
	jesse@nicira.com, fbl@redhat.com, benjamin.poirier@gmail.com,
	jzupka@redhat.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:41331 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755649Ab1JWOhz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Oct 2011 10:37:55 -0400
Received: by wwe6 with SMTP id 6so7785796wwe.1
        for <netdev@vger.kernel.org>; Sun, 23 Oct 2011 07:37:54 -0700 (PDT)
In-Reply-To: <20111023125101.GA20078@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 23 octobre 2011 =C3=A0 14:51 +0200, Jiri Pirko a =C3=A9crit=
 :

> Yes. And team->mode_ops.receive can change only after synchronize_rcu=
 is
> done. It's not possible it changes within the window you are talking =
about.

If it was true, you would not need the synchronize_rcu() call you added
in __team_change_mode() :


----------------------------------------------------------------------

static int __team_change_mode(struct team *team,
                             const struct team_mode *new_mode)
{
       /* Check if mode was previously set and do cleanup if so */
       if (team->mode_kind) {
               void (*exit_op)(struct team *team) =3D team->mode_ops.ex=
it;

               /* Clear ops area so no callback is called any longer */
               team_mode_ops_clear(&team->mode_ops);

               synchronize_rcu();

               if (exit_op)
                       exit_op(team);


-----------------------------------------------------------------------

So the question is : Why do you have this synchronize_rcu() call here ?
