From: Jun Zhao <mypopydev@gmail.com>
Subject: Re: [PATCH v2] ipv4 : igmp : optimize timer modify logic in
 igmp_mod_timer()
Date: Thu, 24 Nov 2011 06:54:45 +0800
Message-ID: <1322088885.5402.17.camel@barry.pixelworks.com>
References: <1322066322-4782-1-git-send-email-mypopydev@gmail.com>
	 <20111123.172814.1626722266908002386.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:59065 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756346Ab1KWWzg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 17:55:36 -0500
Received: by yenq3 with SMTP id q3so1934780yen.19
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2011 14:55:35 -0800 (PST)
In-Reply-To: <20111123.172814.1626722266908002386.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-11-23 at 17:28 -0500, David Miller wrote:
> From: Jun Zhao <mypopydev@gmail.com>
> Date: Thu, 24 Nov 2011 00:38:42 +0800
> 
> > When timer is pending and expires less-than-or-equal-to new delay,
> > we need not used del_timer()/add_timer().
> > 
> > Signed-off-by: Jun Zhao <mypopydev@gmail.com>
> 
> You did not answer Eric's question, why are you optimizing this
> less-used code path?

1). Oh, in the RFC 3376 $5.2, Page 23:

"
   4. If there already is a pending response to a previous Query
      scheduled for this group, and either the new Query is a Group-
      Specific Query or the recorded source-list associated with the
      group is empty, then the group source-list is cleared and a single
      response is scheduled using the group timer.  The new response is
      scheduled to be sent at the earliest of the remaining time for the
      pending report and the selected delay.

   5. If the received Query is a Group-and-Source-Specific Query and
      there is a pending response for this group with a non-empty
      source-list, then the group source list is augmented to contain
      the list of sources in the new Query and a single response is
      scheduled using the group timer.  The new response is scheduled to
      be sent at the earliest of the remaining time for the pending
      report and the selected delay.
"
I think this patch more conform to the RFC.

2). Maybe this is a less-used code path, but we can do better than
current.

3). In the current implementation, "im->tm_running = 1;" is redundant 
