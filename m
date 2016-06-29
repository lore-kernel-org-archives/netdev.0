From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [PATCH] ip route: timeout for routes has to be set in seconds
Date: Wed, 29 Jun 2016 09:25:22 -0700
Message-ID: <20160629092522.494bd502@xeon-e3>
References: <1467156434-2157-1-git-send-email-avagin@openvz.org>
	<15a8916ec54d447b95cff28f99118342@HQ1WP-EXMB11.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: Andrey Vagin <avagin@openvz.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	network dev <netdev@vger.kernel.org>,
	"Andrew Vagin" <avagin@virtuozzo.com>,
	Hangbin Liu <liuhangbin@gmail.com>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:3687 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751160AbcF2Q2R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 12:28:17 -0400
In-Reply-To: <15a8916ec54d447b95cff28f99118342@HQ1WP-EXMB11.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> There's another issue.
> now  the expires transition with HZ happens in kernel when we add
> route with expire, but when we dump,  the expires transition is in the
> user-space:
>                         if (ci->rta_expires != 0)
>                                 fprintf(fp, " expires %dsec",
> ci->rta_expires/hz);
> 
> I'm not sure if  the *hz* value between kernel and user-space are
> always same. I'd like to do this transition both in kernel. just like
> ipaddr's
> valid_lft, preferred_lft.

All API's from applications are supposed to use USER_HZ which is 100hz
on most platforms. Actual kernel internal hz is configurable.

There were some cases legacy of early days where iproute2 had to deal
with kernel hz, mostly in the QoS stuff.
