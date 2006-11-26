From: Patrick McHardy <kaber@trash.net>
Subject: Re: RFC: remove NET_CLS_POLICE?
Date: Sun, 26 Nov 2006 14:21:49 +0100
Message-ID: <456994ED.9040405@trash.net>
References: <20061126062939.GM15364@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org,
	jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:45741 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S935385AbWKZNWD
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Nov 2006 08:22:03 -0500
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20061126062939.GM15364@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> Considering that NET_CLS_POLICE has been marked as obsolete for more 
> than one year, would a patch to remove it be acceptable?

Looking at this, the only reason I thought why we kept this
option was to keep old iproute binaries working. But struct
tc_police in new kernels is bigger than in old ones (new
refcnt, bindcnt and capab members) and both the old and the
action version of the policer check for an exact size match.
Which means old binaries don't work with either NET_CLS_POLICE
or NET_ACT_POLICE. I'll look into fixing this.

One more thing NET_CLS_POLICE affects is CBQ reshape/reclassify
handling, reshape_fail seems to be completely unhandled without
NET_CLS_POLICE and reclassification looks like it behaves
differently with tc actions. I'm not really sure what the
reshape_fail stuff is used for, but it looks like we would loose
a feature. Jamal?

