From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC net-next 1/1] : sctp: denoise deprecation log on SCTP_EVENTS
Date: Thu, 09 Jul 2015 13:54:37 +0200
Message-ID: <559E60FD.5040708@iogearbox.net>
References: <559E4F17.9090107@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevic@redhat.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	mleitner@redhat.com, tuexen@fh-muenster.de
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:50059 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751803AbbGILyu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 07:54:50 -0400
In-Reply-To: <559E4F17.9090107@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/09/2015 12:38 PM, Jamal Hadi Salim wrote:
...
> In the newer kernels this message is extremely noisy. After a quick
> discussion with Daniel it seems to me it will be very hard to get
> existing apps that nobody is going to update to continue to work
> (i.e no forward compat). And newer apps that desire to play in both
> older kernels and new kernels will have to play some tricks to work
> (i.e weak backward compatibility).  These are good reasons
> to totally get rid of this message. At minimal to neutre it.

To put some more context into this, here was the past discussion
on this topic:

   http://www.spinics.net/lists/linux-sctp/msg03596.html

This begs the question, which we need to clarify:

   Can we *ever* get rid of the old UAPI that the RFC proposed
   and later on deprecated?

In the thread, there was a mentioning of 5-6 years schedule, but
I honestly doubt that this would be enough, i.e. for people only
upgrading their kernels, but not being able to touch their legacy
SCTP apps (maybe due to proprietary appliance crap, etc).

A pr_warn_once() would only warn for the first app triggering this
(and not for follow-ups), it would surely take incentives away to
update their code since less annoying, but if the uapi in fact
could never be removed, then why bothering spamming the klog in
the first place? ;) I can understand the deprecation dilemma, but
personally, I would have no problem if we just want to remove the
pr_warn_ratelimited() altogether ...

> The attached change tries to do that. However, if you had multiple
> apps, you will only get warning for the first one.
>
> Will send proper patch when theres some consensus.
>
> cheers,
> jamal
