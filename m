From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 3/3] ifb: move tq from ifb_private
Date: Sat, 04 Dec 2010 09:42:36 -0500
Message-ID: <1291473756.2159.31.camel@mojatatu>
References: <1291442121-3302-1-git-send-email-xiaosuo@gmail.com>
	 <1291442121-3302-3-git-send-email-xiaosuo@gmail.com>
	 <1291472282.2159.8.camel@mojatatu>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f180.google.com ([209.85.161.180]:34406 "EHLO
	mail-gx0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755114Ab0LDOmm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Dec 2010 09:42:42 -0500
Received: by gxk19 with SMTP id 19so5661780gxk.11
        for <netdev@vger.kernel.org>; Sat, 04 Dec 2010 06:42:41 -0800 (PST)
In-Reply-To: <1291472282.2159.8.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2010-12-04 at 09:18 -0500, jamal wrote:

> I like the splice idea but this patch makes me twitch
> a little. What test setup did you use to check it?

Ok, here's one thing you changed which is important. We do:

 -->XXX-->rq-->tq-->XXX-->

rq is controlled by queue limit. 
We only load rq to tq if all of tq is empty. If it is not
we dont move things over. Essentially this is a flow
control scheme. We dont want many sources to be overwhelming
us with packets and every time we grab a txqlen number of packets.
For this reason:
I would be comfortable if all you did was to add the splice
after you skb_peek() - i think that would be a good improvement
which is not bound to break anything else.

cheers,
jamal

