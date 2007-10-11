From: David Miller <davem@davemloft.net>
Subject: Re: bytes received from recvmsg doesn't match FIONREAD
Date: Thu, 11 Oct 2007 16:35:06 -0700 (PDT)
Message-ID: <20071011.163506.111196303.davem@davemloft.net>
References: <1192144096.4147.16.camel@balance>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sdake@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37199
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753134AbXJKXfD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 19:35:03 -0400
In-Reply-To: <1192144096.4147.16.camel@balance>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Steven Dake <sdake@redhat.com>
Date: Thu, 11 Oct 2007 16:08:15 -0700

> I wanted to verify that the size of a multicast UDP message received
> with recvmsg matches the size of the message the kernel thinks the
> message is.
> 
> So I went about using the FIONREAD ioctl as follows:
> 
> res = ioctl (fd, FIONCREAD, &value);
                   ^^^^^^^^^ (typo? should be FIONREAD not FION_C_READ)
> assert (res != -1);
> bytes_received = recvmsg (fd, &msg_recv, MSG_NOSIGNAL | MSG_DONTWAIT);
> assert (bytes_received == value);

I think you want to use SIOCINQ, FIONREAD is only valid on files.

I'm surprised you didn't get an error return from ioctl() as the
VFS code seems to enforce this.
