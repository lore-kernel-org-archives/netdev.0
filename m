From: Cong Wang <cwang@twopensource.com>
Subject: Re: network interfaces called "all", "default" or "config"
Date: Fri, 15 Aug 2014 10:32:50 -0700
Message-ID: <CAHA+R7PpGqNYQcGZrsDB2kfmUM7HdXz2=t2PY8XeouF-PoGOFw@mail.gmail.com>
References: <20140723113314.GA7798@chaz.gmail.com>
	<53CFCD26.1020409@infradead.org>
	<CACsCDOP8DOnB0zZtT_WLhiBXjxXh1aH1eGF9_h0dRN1i9YDU-A@mail.gmail.com>
	<CAHA+R7MLQtYF5vBN0D66Wk8iyGZABf5=Az293gUH6w=4THv8Gw@mail.gmail.com>
	<CACsCDONU9Zq902rj6aJXGZGnPfAWbxsiFe9mMS8usyyUdTYa9A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Randy Dunlap <rdunlap@infradead.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephane Chazelas <stephane.chazelas@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:45537 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751116AbaHORcw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2014 13:32:52 -0400
Received: by mail-la0-f46.google.com with SMTP id b8so2585479lan.33
        for <netdev@vger.kernel.org>; Fri, 15 Aug 2014 10:32:50 -0700 (PDT)
In-Reply-To: <CACsCDONU9Zq902rj6aJXGZGnPfAWbxsiFe9mMS8usyyUdTYa9A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 15, 2014 at 1:33 AM, Stephane Chazelas
<stephane.chazelas@gmail.com> wrote:
> Yes, I know  those are also used for the eth0:1 "aliases", but the bug
> is, since it is allowed to do
>
>     ip link add link eth0 eth0:123 type vlan id 123
>
> Then the
>
>     ip link del link eth0 eth0:123
>
> should be allowed as well. Or probably better to avoid confusion
>
>     ip link add link eth0 foo:bar type vlan id 123
>
> should not be allowed.
>

Good point! I think the reason is that in the past we used ioctl()
to add or remove network interface so kernel just checks that
code path for name alias, so we probably need to check netlink
path as well since it makes really little sense that we allow create
names with a colon but disallow to delete them.

Stephen should know better than me.
