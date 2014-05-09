From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] rtnetlink: call rtnl_lock_unregistering() in rtnl_link_unregister()
Date: Fri, 9 May 2014 11:10:36 -0700
Message-ID: <CAM_iQpUJ7q_RgFzJ7yu5F0aYSSCVAEu64UpwN=md0OyRGHBFAg@mail.gmail.com>
References: <1399657653-4909-1-git-send-email-xiyou.wangcong@gmail.com>
	<20140509110345.417d2b90@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Cong Wang <cwang@twopensource.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:46293 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750744AbaEISKg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 14:10:36 -0400
Received: by mail-ob0-f182.google.com with SMTP id wn1so5255771obc.13
        for <netdev@vger.kernel.org>; Fri, 09 May 2014 11:10:36 -0700 (PDT)
In-Reply-To: <20140509110345.417d2b90@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 9, 2014 at 11:03 AM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Fri,  9 May 2014 10:47:33 -0700
> Cong Wang <xiyou.wangcong@gmail.com> wrote:
>
>> I know making rtnl_lock_unregistering() a macro is ugly, but I don't find
>> any less ugly way to fix it unless we duplicate the code. For long term,
>> I think we should clean up the mess of netdev_run_todo() and net namespce
>> exit code.
>
> Huh, why isn't a real function going to work.

Because in its callers:

+       rtnl_lock_unregistering(net_list, exit_list);
+       rtnl_lock_unregistering(&net_namespace_list, list);

struct net is linked via ->exit_list in net_list and is linked
via ->list in net_namespace_list.

This can't be done without a macro (at least for me). Or
we have to duplicate the code.
