From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 02/10] vxlan: handle skb_clone failure
Date: Wed, 5 Jun 2013 18:31:18 -0700
Message-ID: <20130605183118.0c1a738c@nehalam.linuxnetplumber.net>
References: <1370406254-6341-1-git-send-email-stephen@networkplumber.org>
	<1370406254-6341-2-git-send-email-stephen@networkplumber.org>
	<komnlc$ma8$2@ger.gmane.org>
	<OF0B8CEFF8.C94A266F-ON85257B81.004D331F-85257B81.004D7015@us.ibm.com>
	<CAM_iQpX-RY585=DszU7dURFSFKNhcyDcVLVqDrTxtLep1o_8vw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Stevens <dlstevens@us.ibm.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	netdev-owner@vger.kernel.org
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:48569 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755950Ab3FFBbW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jun 2013 21:31:22 -0400
Received: by mail-pd0-f176.google.com with SMTP id r11so2608989pdi.21
        for <netdev@vger.kernel.org>; Wed, 05 Jun 2013 18:31:22 -0700 (PDT)
In-Reply-To: <CAM_iQpX-RY585=DszU7dURFSFKNhcyDcVLVqDrTxtLep1o_8vw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 6 Jun 2013 08:47:49 +0800
Cong Wang <xiyou.wangcong@gmail.com> wrote:

> On Wed, Jun 5, 2013 at 10:05 PM, David Stevens <dlstevens@us.ibm.com> wrote:
> > netdev-owner@vger.kernel.org wrote on 06/05/2013 02:59:56 AM:
> >
> >> From: Cong Wang <xiyou.wangcong@gmail.com>
> >> If OOM, shouldn't we exit immediately instead of continue handle the
> >> next one?
> >
> > It could be a temporary condition; trying again doesn't really hurt,
> > in case some do go through. So, I prefer this, but could live with
> > bailing for all destinations, too.
> >
> 
> The problem we don't know if it is temporary or not, unless mm provides
> EAGAIN?
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

There is no EAGAIN in the network transmit path, it is not called from
user context.
