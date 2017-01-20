From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 0/2] net: ipv6: Improve user experience with
 multipath routes
Date: Fri, 20 Jan 2017 12:31:44 -0700
Message-ID: <90d6fdce-7780-b864-0e89-db262dec6fa1@cumulusnetworks.com>
References: <1484892626-14257-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:33656 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752101AbdATTbv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 14:31:51 -0500
Received: by mail-pf0-f181.google.com with SMTP id y143so24589432pfb.0
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 11:31:51 -0800 (PST)
Received: from ?IPv6:2601:284:8202:3440:6da4:dd1a:6c14:ae7f? ([2601:284:8202:3440:6da4:dd1a:6c14:ae7f])
        by smtp.googlemail.com with ESMTPSA id c11sm18662224pfe.68.2017.01.20.11.31.49
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jan 2017 11:31:50 -0800 (PST)
In-Reply-To: <1484892626-14257-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/19/17 11:10 PM, David Ahern wrote:
> This series closes a couple of gaps between IPv4 and IPv6 with respect
> to multipath routes:
...
> In both cases, the new behavior requires users to opt in by setting a new
> flag, RTM_F_ALL_NEXTHOPS, in the rtm_flags of struct rtmsg which is
> expected to be the ancillary header in the netlink request received from
> the user. A program must opt in to the new behavior so as to not break
> any existing applications.
> 
> The opt-in behavior works for both route deletes and dumps (the two
> differences noted above), but not for notifications as notifications
> do not take user input to specify flags. The only way to have
> notifications generate RTA_MULTIPATH encodings is to have a gobal
> flag -- e.g., sysctl. I'd prefer not to add a sysctl knob for this
> backwards compatibility.

BTW, I am in favor of not requiring a user API for this but just doing it. I can't imagine anyone working with multipath routes not wanting the efficiency of the RTA_MULTIPATH attribute. These patches require an API only because of the rule not to break userspace. If we conclude to just do it without an API, the multipath_add and multipath_del need to be modified to only send a notification once at the end of the actions.
