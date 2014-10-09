From: Omar Sandoval <osandov@osandov.com>
Subject: Re: [PATCH] net sched: text ematch: zero out ts_state before using it
Date: Thu, 9 Oct 2014 14:54:41 -0700
Message-ID: <20141009215441.GA1830@mew.dhcp4.washington.edu>
References: <1412870721-31061-1-git-send-email-osandov@osandov.com>
 <CAHA+R7Ot5u6F1zi4egLqOXPWbQrdLxdUQybaFEp5_aa463d4Bw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:55503 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751032AbaJIVyo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2014 17:54:44 -0400
Received: by mail-pd0-f171.google.com with SMTP id ft15so456949pdb.2
        for <netdev@vger.kernel.org>; Thu, 09 Oct 2014 14:54:43 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAHA+R7Ot5u6F1zi4egLqOXPWbQrdLxdUQybaFEp5_aa463d4Bw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 09, 2014 at 02:48:54PM -0700, Cong Wang wrote:
> On Thu, Oct 9, 2014 at 9:05 AM, Omar Sandoval <osandov@osandov.com> wrote:
> > textsearch_find zeroes out the offset, but the control buffer (which may or may
> > not matter in this case) needs to be zeroed out as well.
> 
> Why? skb_prepare_seq_read() initializes the cb.
> 
> Also, the comment says:
> 
>  * @state: uninitialized textsearch state variable

Mm, thanks, I missed that. It looks like every other caller of skb_find_text is
doing an unnecessary memset in that case. Disregard this, I guess.
-- 
Omar
