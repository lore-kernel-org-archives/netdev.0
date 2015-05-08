From: Cong Wang <cwang@twopensource.com>
Subject: Re: [RFC PATCH net-next 00/11] netns: don't switch namespace while
 creating kernel sockets
Date: Fri, 8 May 2015 09:33:26 -0700
Message-ID: <CAHA+R7MKra6U4ESu9LvE2f9YGXaD5CZ-DLziNHfWhej+AKH6tg@mail.gmail.com>
References: <1430988770-28907-1-git-send-email-ying.xue@windriver.com>
	<87wq0kcqlm.fsf@x220.int.ebiederm.org>
	<554C78BE.100@windriver.com>
	<87a8xfba44.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ying Xue <ying.xue@windriver.com>, netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Pavel Emelyanov <xemul@openvz.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, maxk@qti.qualcomm.com,
	Stephen Hemminger <stephen@networkplumber.org>,
	Thomas Graf <tgraf@suug.ch>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Tom Herbert <tom@herbertland.com>,
	James Chapman <jchapman@katalix.com>,
	Erik Hugne <erik.hugne@ericsson.com>, jon.maloy@ericsson.com,
	Simon Horman <horms@verge.net.au>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:33554 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753631AbbEHQd1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2015 12:33:27 -0400
Received: by wgin8 with SMTP id n8so77458986wgi.0
        for <netdev@vger.kernel.org>; Fri, 08 May 2015 09:33:26 -0700 (PDT)
In-Reply-To: <87a8xfba44.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 8, 2015 at 4:07 AM, Eric W. Biederman <ebiederm@xmission.com> wrote:
>
> I agree which is why my implementation of lock_network_namespaces below
> loops until there are no exiting network namespaces.
>

It is easy to have live lock since you keep dropping and acquire netns mutex
in a loop.
