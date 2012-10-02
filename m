From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: network namespace and kernel bind issue
Date: Mon, 1 Oct 2012 17:48:41 -0700
Message-ID: <20121001174841.41fcd637@s6510.linuxnetplumber.net>
References: <20121001141609.14639bc0@nehalam.linuxnetplumber.net>
	<20121001145838.5eafef4c@nehalam.linuxnetplumber.net>
	<87fw5xeryf.fsf@xmission.com>
	<20121001155702.5b5e2188@nehalam.linuxnetplumber.net>
	<87y5jpdbzo.fsf@xmission.com>
	<20121001163226.3873ca58@nehalam.linuxnetplumber.net>
	<871uhhd82p.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49955 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752350Ab2JBAso (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Oct 2012 20:48:44 -0400
In-Reply-To: <871uhhd82p.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The problem was vxlan wasn't doing sk_change_net on the created socket.

I'm testing that fix.

The long term fix is to change sock_create_kern() to take a 'struct net'
argument. This would avoid the trap of having to change the namespace.
Also several places using __sock_create() could use it.

L2TP still looks to have several namespace related issues.
