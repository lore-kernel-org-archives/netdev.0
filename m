From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [Question] Should `CAP_NET_ADMIN` be needed when opening
 `/dev/ppp`?
Date: Tue, 3 May 2016 12:12:40 +0200
Message-ID: <20160503101240.GA1304@alphalink.fr>
References: <2BEB0C68-EBC6-4A8F-A751-DE8F4A2C9D2C@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Wang Shanker <shankerwangmiao@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:48241 "EHLO
	zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755495AbcECKMo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2016 06:12:44 -0400
Content-Disposition: inline
In-Reply-To: <2BEB0C68-EBC6-4A8F-A751-DE8F4A2C9D2C@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 01, 2016 at 09:38:57PM +0800, Wang Shanker wrote:
> static int ppp_open(struct inode *inode, struct file *file)
> {
> 	/*
> 	 * This could (should?) be enforced by the permissions on /dev/ppp.
> 	 */
> 	if (!capable(CAP_NET_ADMIN))
> 		return -EPERM;
> 	return 0;
> }
> ```
> 
> I wonder why CAP_NET_ADMIN is needed here, rather than leaving it to the
> permission of the device node. If there is no need, I suggest that the
> CAP_NET_ADMIN check be removed.
> 
If this test was removed here, then it'd have to be added again in the
PPPIOCNEWUNIT ioctl, at the very least, because creating a netdevice
should require CAP_NET_ADMIN. Therefore that wouldn't help for your
case.
I don't know why the test was placed in ppp_open() in the first place,
but changing it now would have side effects on user space. So I'd
rather leave the code as is.
