From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH V5 2/2] bonding: Prevent duplicate userspace notification
Date: Fri, 26 May 2017 13:46:46 -0600
Message-ID: <69124b76-db1d-77d4-e850-0421a83c90b0@gmail.com>
References: <1495726316-27626-1-git-send-email-vyasevic@redhat.com>
 <1495726316-27626-3-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, jiri@resnulli.us, vfalico@gmail.com,
        andy@greyhouse.net, Vladislav Yasevich <vyasevic@redhat.com>
To: Vladislav Yasevich <vyasevich@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35306 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754606AbdEZTqt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 15:46:49 -0400
Received: by mail-pf0-f195.google.com with SMTP id u26so4939690pfd.2
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 12:46:49 -0700 (PDT)
In-Reply-To: <1495726316-27626-3-git-send-email-vyasevic@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/25/17 9:31 AM, Vladislav Yasevich wrote:
> Whenever a user changes bonding options, a NETDEV_CHANGEINFODATA
> notificatin is generated which results in a rtnelink message to
> be sent.  While runnig 'ip monitor', we can actually see 2 messages,
> one a result of the event, and the other a result of state change
> that is generated bo netdev_state_change().  However, this is not
> always the case. If bonding changes were done via sysfs or ifenslave
> (old ioctl interface), then only 1 message is seen.
> 
> This patch removes duplicate messages in the case of using netlink
> to configure bonding.  It introduceds a separte function that
> triggers a netdev event and uses that function in the syfs and ioctl
> cases.
> 
> This was discovered while auditing all the different envents and
> continues the effort of cleaning up duplicated netlink messages.
> 
> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
> ---
>  drivers/net/bonding/bond_main.c    |  3 ++-
>  drivers/net/bonding/bond_options.c | 27 +++++++++++++++++++++++++--
>  include/net/bond_options.h         |  2 ++
>  3 files changed, 29 insertions(+), 3 deletions(-)

LGTM

Acked-by: David Ahern <dsahern@gmail.com>
