From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] core: Correct an over-stringent device loop detection.
Date: Sun, 3 May 2015 19:46:32 +0200
Message-ID: <20150503174632.GA2438@nanopsycho>
References: <1430616824-9006-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jpirko@redhat.com, vfalico@gmail.com,
	Vladislav Yasevich <vyasevic@redhat.com>
To: Vladislav Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:32805 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750990AbbECRqh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 May 2015 13:46:37 -0400
Received: by wief7 with SMTP id f7so62837702wie.0
        for <netdev@vger.kernel.org>; Sun, 03 May 2015 10:46:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1430616824-9006-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, May 03, 2015 at 03:33:44AM CEST, vyasevich@gmail.com wrote:
>The code in __netdev_upper_dev_link() has an over-stringent
>loop detection logic that actually prevents valid configurations
>from working correctly.
>
>In particular, the logic returns an error if an upper device
>is already in the list of all upper devices for a given dev.
>This particular check seems to be a overzealous as it disallows
>perfectly valid configurations.  For example:
>  # ip l a link eth0 name eth0.10 type vlan id 10
>  # ip l a dev br0 typ bridge
>  # ip l s eth0.10 master br0
>  # ip l s eth0 master br0  <--- Will fail
>
>If you switch the last two commands (add eth0 first), then both
>will succeed.  If after that, you remove eth0 and try to re-add
>it, it will fail!
>
>It appears to be enough to simply check adj_list to keeps things
>safe.
>
>I've tried stacking multiple devices multiple times in all different
>combinations, and either rx_handler registration prevented the stacking
>of the device linking cought the error.
>
>Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>

Acked-by: Jiri Pirko <jiri@resnulli.us>
