From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH][IPV6] fixed authentication error with TCP
Date: Thu, 7 Aug 2003 22:05:39 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030807220539.4555db2d.davem@redhat.com>
References: <20030806164413.669ef5f8.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, usagi@linux-ipv6.org,
   latten@austin.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Kazunori Miyazawa <kazunori@miyazawa.org>
In-Reply-To: <20030806164413.669ef5f8.kazunori@miyazawa.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 6 Aug 2003 16:44:13 +0900
Kazunori Miyazawa <kazunori@miyazawa.org> wrote:

> Miss Joy (@IBM) and I investigated the bug that "authentication
> error" occured with using TCP and AH in IPv6. This patch fixes the
> bug. This patch makes the kernel consider extension header length in
> a dst.
> 
> This pach works with my previous patch which fixes zero-clear in ah6_input.
> 
> Please append the name "Joy Latten" into the log.

I have applied this patch, thank you.

But I see a small area for improvement.  Look at the place inside
of ip6_dst_lookup() where we do source address selection.  If this
fails, we mark error to dst->error.

Is it correct?  This 'dst' route might otherwise be perfectly fine.
But now that dst->error is set, it is poisoned for other users
and they are not able to use it.

A similar case occurs further down after the xfrm_lookup() call, but
this one I think is correct.

It seems to me that it is only OK for dst->error to be set on routes
that may not be used validly for anything.

Alexey, do I understand this stuff correctly?
