From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: new leaks in bridging code.
Date: Mon, 31 Mar 2014 12:54:06 +0900
Message-ID: <5338E6DE.8080702@lab.ntt.co.jp>
References: <533730f2396e8_1c4bb46874192e@209.249.196.67.mail> <20140329210102.GA22516@redhat.com> <1396146501.2182.5.camel@localhost.localdomain> <20140330024709.GA25793@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dave Jones <davej@redhat.com>,
	Toshiaki Makita <toshiaki.makita1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:39295 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752811AbaCaDyT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Mar 2014 23:54:19 -0400
In-Reply-To: <20140330024709.GA25793@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(2014/03/30 11:47), Dave Jones wrote:
> On Sun, Mar 30, 2014 at 11:28:21AM +0900, Toshiaki Makita wrote:
>  > On Sat, 2014-03-29 at 17:01 -0400, Dave Jones wrote:
>  > > yesterdays bridging changes introduced leaks in the exit paths..
>  > > 
>  > The patch has nothing to do with this memory leak.
> 
> Good point, the checker only picked up it as 'new' because of the
> additional call to vlan_untag.
> 
>  > It has existed since br_allowed_ingress was introduced.
>  > I'm working on fixing it.
>  > http://marc.info/?t=139598775400004&r=1&w=2
> 
> Great! (I'm behind on email so hadn't seen this thread).
> 

Considering more deeply about why your checker claimed that vlan_untag()
in br_allowed_ingress() is bad, I got an idea that it should have
pointed out not resource leakage but double free of skb.

vlan_untag() may free skbs, but we also free skbs in caller side
(br_handle_frame_finish()) without updating skb pointers to NULL.

I'll also fix this problem.

Thanks,
Toshiaki Makita
