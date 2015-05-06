From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next 4/6] netns: notify new nsid outside __peernet2id()
Date: Wed, 06 May 2015 15:39:52 +0200
Message-ID: <554A19A8.1080304@6wind.com>
References: <1430906288-5108-1-git-send-email-nicolas.dichtel@6wind.com> <1430906288-5108-5-git-send-email-nicolas.dichtel@6wind.com> <20150506114832.GF25248@pox.localdomain>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, ebiederm@xmission.com
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:36336 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750737AbbEFNjz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 09:39:55 -0400
Received: by wizk4 with SMTP id k4so202814788wiz.1
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 06:39:54 -0700 (PDT)
In-Reply-To: <20150506114832.GF25248@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 06/05/2015 13:48, Thomas Graf a =E9crit :
[snip]
>
> Since you need the allocation behaviour from one call site only it
> might be cleaner to add a __peernet2id_alloc() which is used from
> the old __peernet2id() so you can call __peernet2id_alloc() from
> peernet2id_alloc() and avoid putting these ugly bool alloc =3D false
> in all other call sites.
You're absolutely right.

Side note:

bool false =3D false;
=2E..
__peernet2id_alloc(net, peer, &false);

This compiles but the behavior is unexpected. In __peernet2id_alloc() t=
he bool
is true. I need to think a bit more to explain that.
