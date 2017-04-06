From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net] team: call netdev_change_features out of team lock
Date: Thu, 6 Apr 2017 15:24:58 +0200
Message-ID: <20170406132458.GB2064@nanopsycho>
References: <dad7cdf64679977bd3ba512180fcfb8ec96d9129.1491457288.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, davem@davemloft.net
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:35371 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753497AbdDFNZA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 09:25:00 -0400
Received: by mail-io0-f194.google.com with SMTP id f103so4280584ioi.2
        for <netdev@vger.kernel.org>; Thu, 06 Apr 2017 06:25:00 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <dad7cdf64679977bd3ba512180fcfb8ec96d9129.1491457288.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Apr 06, 2017 at 07:41:28AM CEST, lucien.xin@gmail.com wrote:
>Commit f6988cb63a4e ("team: don't call netdev_change_features under
>team->lock") fixed the issue calling netdev_change_features under
>team->lock for team_compute_features.
>
>But there are still two places where it calls netdev_change_features
>under team->lock, team_port_add and team_port_del. It may cause a
>dead lock when the slave port with LRO enabled is added.
>
>This patch is to fix this dead lock by moving netdev_change_features
>out of team_port_add and team_port_del, and call it after unlocking
>the team lock.
>
>Reported-by: Patrick Talbert <ptalbert@redhat.com>
>Signed-off-by: Xin Long <lucien.xin@gmail.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
