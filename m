From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 2/5] igb: fix race accessing page->_count
Date: Fri, 10 Oct 2014 04:47:32 -0700
Message-ID: <1412941652.9362.8.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1412918694-22882-1-git-send-email-edumazet@google.com>
	 <1412918694-22882-3-git-send-email-edumazet@google.com>
	 <CAL3LdT5_uQ07kbB+N6RY1yMe3yfko6O2g+QsTaz1-TDk7A1CCQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	Andres Lagar-Cavilla <andreslc@google.com>,
	Greg Thelen <gthelen@google.com>,
	Hugh Dickins <hughd@google.com>,
	David Rientjes <rientjes@google.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33329 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751575AbaJJLre (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 07:47:34 -0400
Received: by mail-pa0-f42.google.com with SMTP id bj1so1623245pad.15
        for <netdev@vger.kernel.org>; Fri, 10 Oct 2014 04:47:34 -0700 (PDT)
In-Reply-To: <CAL3LdT5_uQ07kbB+N6RY1yMe3yfko6O2g+QsTaz1-TDk7A1CCQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-10-09 at 22:55 -0700, Jeff Kirsher wrote:
> On Thu, Oct 9, 2014 at 10:24 PM, Eric Dumazet <edumazet@google.com> wrote:
> > This is illegal to use atomic_set(&page->_count, 2) even if we 'own'
> > the page. Other entities in the kernel need to use get_page_unless_zero()
> > to get a reference to the page before testing page properties, so we could
> > loose a refcount increment.
> >
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> 
> Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> 
> Since this is apart of a series, if the changes to skbuff are ok, then
> the changes to the Intel drivers are ok.

Thanks Jeff, I am sending v2 including your Acked-by and ixgbe title
fix.
