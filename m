From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] isdnloop: NUL-terminate strings from userspace
Date: Tue, 01 Apr 2014 16:18:38 -0400 (EDT)
Message-ID: <20140401.161838.1562296825577866979.davem@davemloft.net>
References: <533A990D.2040609@oracle.com>
	<20140401110255.GH24150@order.stressinduktion.org>
	<20140401123534.GE18506@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vegard.nossum@oracle.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140401123534.GE18506@mwanda>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 1 Apr 2014 15:35:34 +0300

> I don't understand what you think the point of strlcpy() is, if it's not
> to deal with source strings which aren't NUL terminated.

If strlcpy() is meant to handle non-NULL terminated strings, then it's
kernel doc needs to be adjusted.

/**
 * strlcpy - Copy a %NUL terminated string into a sized buffer
 * @dest: Where to copy the string to
 * @src: Where to copy the string from
 * @size: size of destination buffer
 *
 * Compatible with *BSD: the result is always a valid
 * NUL-terminated string that fits in the buffer (unless,
 * of course, the buffer size is zero). It does not pad
 * out the result like strncpy() does.
 */

That says to me that 'src' is expected to be NULL terminated.

Furthermore, I like YOSHIFUJI Hideaki's idea that we should
actually validate the string and return -EINVAL if it is not
given to us NULL terminated.
