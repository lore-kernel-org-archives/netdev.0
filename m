From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netns: deinline net_generic()
Date: Tue, 14 Apr 2015 08:25:26 -0700
Message-ID: <1429025126.7346.36.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1429014311-19868-1-git-send-email-dvlasenk@redhat.com>
	 <1429017572.7346.20.camel@edumazet-glaptop2.roam.corp.google.com>
	 <552D1CD7.7040705@redhat.com>
	 <1429021301.7346.29.camel@edumazet-glaptop2.roam.corp.google.com>
	 <552D2C89.6080601@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Jan Engelhardt <jengelh@medozas.de>,
	Jiri Pirko <jpirko@redhat.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Denys Vlasenko <dvlasenk@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:32925 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753471AbbDNPZb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 11:25:31 -0400
In-Reply-To: <552D2C89.6080601@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-04-14 at 17:04 +0200, Denys Vlasenko wrote:
> On 04/14/2015 04:21 PM, Eric Dumazet wrote:
> > On Tue, 2015-04-14 at 15:57 +0200, Denys Vlasenko wrote:
> > 
> >> My allyesconfig, with BUG_ON's commented out:
> >>
> > 
> > Right. But I can tell you nobody uses lockdep on a production kernel.
> > 
> > Here, at Google, we get what I described.
> 
> I'm trying to get to the .config which generates a small function.
> 
> So far, with LOCKDEP off, it is still this big:
> 

If you read exactly what I wrote, you'll understand that at Google,
rcu_read_lock() & rcu_read_unlock() are nop.

Your patch is based on a worst case scenario, and will slow down our use
case.
