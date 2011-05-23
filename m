From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 1/3] vlan: Do not support clearing VLAN_FLAG_REORDER_HDR
Date: Mon, 23 May 2011 14:00:48 -0700
Message-ID: <20110523140048.777fb378@nehalam>
References: <1302241713-3637-1-git-send-email-jpirko@redhat.com>
	<20110412.141645.112604563.davem@davemloft.net>
	<BANLkTikSKiYoiOLB=i7qjR0N--CAQ2dHWw@mail.gmail.com>
	<20110521072925.GA2588@jirka.orion>
	<BANLkTinZUATEjBij+rwBTn=n-Tau5qHPWw@mail.gmail.com>
	<4DD7BB61.9050200@gmail.com>
	<BANLkTinqFJa-B7E7tonzOKGV4etZHUkUug@mail.gmail.com>
	<4DD87C25.4030701@gmail.com>
	<20110522062915.GA2611@jirka.orion>
	<m17h9jp7js.fsf@fess.ebiederm.org>
	<BANLkTi=4JJa-J-p_JbY1PfooT75KfSB4uA@mail.gmail.com>
	<m1ei3qjzix.fsf_-_@fess.ebiederm.org>
	<4DD97A44.2020708@candelatech.com>
	<m1wrhigy37.fsf@fess.ebiederm.org>
	<4DD9F81D.6070806@candelatech.com>
	<m1y61x94g1.fsf@fess.ebiederm.org>
	<4DDA8C42.3090009@candelatech.com>
	<4DDAB72B.9050101@gmail.com>
	<4DDAC26C.2070601@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Nicolas de =?UTF-8?B?UGVzbG/DvGFu?= <nicolas.2p.debian@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>,
	Jiri Pirko <jpirko@redhat.com>,
	Changli Gao <xiaosuo@gmail.com>, netdev@vger.kernel.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	andy@greyhouse.net, Jesse Gross <jesse@nicira.com>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:57800 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1030231Ab1EWVBq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2011 17:01:46 -0400
In-Reply-To: <4DDAC26C.2070601@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Well, yes..unless perhaps when the REORDER_HDR flag is enabled.
> 
> As for when the tag is added/removed, as long as we don't end up doing
> a remove and then an add (in software), and as long as the pkt is correct
> going to user-space, it doesn't matter to me.
> 
> It would be lame to remove it in software and then re-add it,
> unless absolutely required for some reason.

IMHO the REORDER_HDR flag was a design mistake. It means supporting
two different API's for the application. For a packet capture application
it means the format of the packet will be different based on how
the VLAN was created. And the vlan was created outside the application.

If there was a requirement to support both formats, then it should
be a property of the AF_PACKET socket.  The application can then do
an setsockopt() to control the format of the data. The issue is
for things like mmap/AF_PACKET the re-inserted form will be slower
since data has to be copied.


