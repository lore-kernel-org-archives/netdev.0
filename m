From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net] vxlan: fix crash on module removal
Date: Wed, 5 Jun 2013 18:32:47 -0700
Message-ID: <20130605183247.28c41cc2@nehalam.linuxnetplumber.net>
References: <1370406254-6341-1-git-send-email-stephen@networkplumber.org>
	<1370406254-6341-3-git-send-email-stephen@networkplumber.org>
	<20130605083700.2a09e379@nehalam.linuxnetplumber.net>
	<koonje$ssv$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:34224 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755990Ab3FFBcv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jun 2013 21:32:51 -0400
Received: by mail-pd0-f172.google.com with SMTP id t10so2632811pdi.31
        for <netdev@vger.kernel.org>; Wed, 05 Jun 2013 18:32:51 -0700 (PDT)
In-Reply-To: <koonje$ssv$1@ger.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 6 Jun 2013 01:11:11 +0000 (UTC)
Cong Wang <xiyou.wangcong@gmail.com> wrote:

> On Wed, 05 Jun 2013 at 15:37 GMT, Stephen Hemminger <stephen@networkplumber.org> wrote:
> > If vxlan is removed with active vxlan's it would crash because
> > rtnl_link_unregister (which calls vxlan_dellink), was invoked
> > before unregister_pernet_device (which calls vxlan_stop).
> >
> 
> Two points:
> 
> 1. There are still many others drivers calling them in such order...
> 2. The removal should be in a reverse order of creation, at least in
> theory.
> 
> I mean this *might* indicate something wrong.

1. Other drivers either don't have the dependency or are broken.
   It makes no sense to stop a device that is deleted.

2. The normal creation order is
   vxlan_setup
   vxlan_newlink
   vxlan_open

     
