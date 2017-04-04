From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] ss: replace all zero characters in a unix name to '@'
Date: Tue, 4 Apr 2017 14:44:56 -0700
Message-ID: <20170404144456.5e9b70fe@xeon-e3>
References: <1491010317-27083-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrei Vagin <avagin@virtuozzo.com>
To: Andrei Vagin <avagin@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:33265 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753190AbdDDVo7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 17:44:59 -0400
Received: by mail-pg0-f50.google.com with SMTP id x125so164109246pgb.0
        for <netdev@vger.kernel.org>; Tue, 04 Apr 2017 14:44:59 -0700 (PDT)
In-Reply-To: <1491010317-27083-1-git-send-email-avagin@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat,  1 Apr 2017 04:31:57 +0300
Andrei Vagin <avagin@openvz.org> wrote:

> From: Andrei Vagin <avagin@virtuozzo.com>
> 
> A name of an abstract socket can contain zero characters.
> Now we replace only the first character. If a name contains more
> than one zero character, the ss tool shows only a part of the name:
> u_str  UNCONN    0    0     @                            1931097   * 0
> 
> the output with this patch:
> u_str  UNCONN    0    0     @@zdtm-./sk-unix-unconn-23/@ 1931097   * 0
> 
> Signed-off-by: Andrei Vagin <avagin@virtuozzo.com>

This patch duplicates changes that are already in current version.

commit 878dadc79d247aa37b67fb30608e58ef1f9ab9ff
Author: Isaac Boukris <iboukris@gmail.com>
Date:   Sat Oct 29 22:20:19 2016 +0300

    iproute2: ss: escape all null bytes in abstract unix domain socket
    
    Abstract unix domain socket may embed null characters,
    these should be translated to '@' when printed by ss the
    same way the null prefix is currently being translated.
    
    Signed-off-by: Isaac Boukris <iboukris@gmail.com>
