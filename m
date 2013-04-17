From: Dave Jones <davej@redhat.com>
Subject: Re: oops in udpv6_sendmsg
Date: Wed, 17 Apr 2013 10:11:38 -0400
Message-ID: <20130417141138.GA17648@redhat.com>
References: <20130329184006.GA23893@redhat.com>
 <1364582958.5113.49.camel@edumazet-glaptop>
 <1364865839.5113.165.camel@edumazet-glaptop>
 <20130417010213.GA9027@redhat.com>
 <1366164132.3205.21.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54361 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966434Ab3DQOLm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Apr 2013 10:11:42 -0400
Content-Disposition: inline
In-Reply-To: <1366164132.3205.21.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 16, 2013 at 07:02:12PM -0700, Eric Dumazet wrote:

 > > rax is all kinds of crazy. 7ae9fffffff2b8ff doesn't look anything like an address.
 > 
 > rt->rt6i_idev contains garbage. It looks like a dst refcount issue.
 > 
 > Wow, it seems ip6_append_data() calls sock_alloc_send_skb() and can
 > release socket lock while waiting for buffer space.
 > 
 > This completely defeats corking, as another thread can mess with
 > cork->dst at the same time.
 > 
 > We need to hold dst before sleeping in sock_alloc_send_skb()

good news is that with some changes, I was able to make current
trinity reproduce this in seconds rather than hours..

./trinity -q -l off -n -c sendmsg -c connect 

on current tree seems to reliably trigger it for me.

	Dave 
