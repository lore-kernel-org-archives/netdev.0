From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v7 0/4] Support administratively closing application
 sockets
Date: Wed, 16 Dec 2015 15:35:35 -0800
Message-ID: <1450308935.8474.103.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1450236605-87170-1-git-send-email-lorenzo@google.com>
	 <20151216074334.593a1ad6@xeon-e3>
	 <1450281013.8474.73.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5671C1A3.30207@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Lorenzo Colitti <lorenzo@google.com>, netdev@vger.kernel.org,
	davem@davemloft.net, hannes@stressinduktion.org, ek@google.com,
	tom@herbertland.com, zenczykowski@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:33261 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753610AbbLPXfh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2015 18:35:37 -0500
Received: by mail-pa0-f48.google.com with SMTP id ur14so31247329pab.0
        for <netdev@vger.kernel.org>; Wed, 16 Dec 2015 15:35:37 -0800 (PST)
In-Reply-To: <5671C1A3.30207@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-12-16 at 14:55 -0500, Jamal Hadi Salim wrote:
> On 15-12-16 10:50 AM, Eric Dumazet wrote:
> > On Wed, 2015-12-16 at 07:43 -0800, Stephen Hemminger wrote:
> >
> >>
> >> I see no security checks in the diag infrastructure.
> >> Up until now diag has been read-only access and therefore has been
> >> allowed for all users.
> >
> > It is still allowed to all users.
> >
> > Only the 'destroy' operation is restricted.
> 
> The question i had was the opposite when i saw this: why are
> regular users allowed to read admin (and any other users) details?;->
> On this specific feature: why, as a regular user, I cant close
> connections attributed to me (and have to use CAP_NET_ADMIN)?

I guess that we need to be careful here.

socket can be shared by fd passing to multiple users.

Who really owns it ?
