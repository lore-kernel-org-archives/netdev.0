From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [Patch net] rtnetlink: call rtnl_lock_unregistering() in
 rtnl_link_unregister()
Date: Fri, 9 May 2014 12:02:41 -0700
Message-ID: <20140509120241.3b628dc1@nehalam.linuxnetplumber.net>
References: <1399657653-4909-1-git-send-email-xiyou.wangcong@gmail.com>
	<20140509110345.417d2b90@nehalam.linuxnetplumber.net>
	<CAM_iQpUJ7q_RgFzJ7yu5F0aYSSCVAEu64UpwN=md0OyRGHBFAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Cong Wang <cwang@twopensource.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:55931 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754499AbaEITCp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 15:02:45 -0400
Received: by mail-pd0-f181.google.com with SMTP id w10so3991161pde.26
        for <netdev@vger.kernel.org>; Fri, 09 May 2014 12:02:45 -0700 (PDT)
In-Reply-To: <CAM_iQpUJ7q_RgFzJ7yu5F0aYSSCVAEu64UpwN=md0OyRGHBFAg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 9 May 2014 11:10:36 -0700
Cong Wang <xiyou.wangcong@gmail.com> wrote:

> On Fri, May 9, 2014 at 11:03 AM, Stephen Hemminger
> <stephen@networkplumber.org> wrote:
> > On Fri,  9 May 2014 10:47:33 -0700
> > Cong Wang <xiyou.wangcong@gmail.com> wrote:
> >
> >> I know making rtnl_lock_unregistering() a macro is ugly, but I don't find
> >> any less ugly way to fix it unless we duplicate the code. For long term,
> >> I think we should clean up the mess of netdev_run_todo() and net namespce
> >> exit code.
> >
> > Huh, why isn't a real function going to work.
> 
> Because in its callers:
> 
> +       rtnl_lock_unregistering(net_list, exit_list);
> +       rtnl_lock_unregistering(&net_namespace_list, list);
> 
> struct net is linked via ->exit_list in net_list and is linked
> via ->list in net_namespace_list.
> 
> This can't be done without a macro (at least for me). Or
> we have to duplicate the code.

macro method is too ugly, figure out a better way.
