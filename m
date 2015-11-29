From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [iproute PATCH RFC] libnetlink: introduce DECLARE_NLREQ
Date: Sun, 29 Nov 2015 12:07:52 -0800
Message-ID: <20151129120752.73834f50@xeon-e3>
References: <1448544365-23153-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:38959 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752126AbbK2UHs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2015 15:07:48 -0500
In-Reply-To: <1448544365-23153-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 26 Nov 2015 14:26:05 +0100
Phil Sutter <phil@nwl.cc> wrote:

> This macro aims to simplify most netlink users' pattern to prepare a
> request, which is to create an unnamed struct and initialize it:
> 
> | struct {
> |	struct nlmsghdr n;
> |	struct whatever foo;
> |	char buf[arbitrary number];
> | } req;
> |
> | memset(&req, 0, sizeof(req));
> | req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct whatever));
> | req.n.nlmsg_flags = NLM_F_REQUEST;
> 
> Having this patch applied, the above can be replaced by a static
> initializer like so:
> 
> | DECLARE_NLREQ(req, n, struct whatever foo, arbitrary number);
> 
> There is an added benefit, as well: Due to explicit alignment, the
> requested tailroom is really as big as requested no matter what size
> struct whatever really is.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
> This patch is RFC because I want to wait for peer review and upstream
> acceptance before sending in the big refactoring patch itself.
> ---
>  include/libnetlink.h | 11 +++++++++++
>  1 file changed, 11 insertions(+)

I am not a fan of complex macros. But netlink seems to get lots of them.
You need to add more parens round arguments (like name).

Really longterm would rather iproute2 switched to a cleaner library like libmnl
