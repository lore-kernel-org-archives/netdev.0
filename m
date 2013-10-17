From: Kristian Evensen <kristian.evensen@gmail.com>
Subject: Re: [PATCH net-next] fib_trie: Send RTM_DELROUTE when link goes down
Date: Thu, 17 Oct 2013 22:14:52 +0200
Message-ID: <CAKfDRXjctGkcqSt9cM=iWbckLt4=7n8434WAA8rr4_cEofEO=Q@mail.gmail.com>
References: <CAKfDRXizw1TaK-oHrAQv8Hi80gKiUHjQ6d21o3MOQpuVkcXSow@mail.gmail.com>
	<1382028894-14236-1-git-send-email-kristian.evensen@gmail.com>
	<1382030610.22110.112.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Network Development <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:41296 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762335Ab3JQUOx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 16:14:53 -0400
Received: by mail-pd0-f169.google.com with SMTP id q10so2172610pdj.0
        for <netdev@vger.kernel.org>; Thu, 17 Oct 2013 13:14:52 -0700 (PDT)
In-Reply-To: <1382030610.22110.112.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Thu, Oct 17, 2013 at 7:23 PM, Joe Perches <joe@perches.com> wrote:
>
> Perhaps this memset should be moved into the
> list_for_each_entry_safe loop where cfg is used.

Thanks for your comment. I decided to put it there to avoid calling it
for each route that will be deleted. Since the struct is never
modified (only read in fib_rtmsg()) and we have the rtnl_lock, I
assumed it to be safe. Are there cases where this assumption is wrong?

-Kristian
