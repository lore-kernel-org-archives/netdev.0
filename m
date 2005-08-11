From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] sockaddr_ll change for IPoIB interface
Date: Thu, 11 Aug 2005 12:49:16 -0700 (PDT)
Message-ID: <20050811.124916.77057824.davem@davemloft.net>
References: <1123786117.4403.5835.camel@hal.voltaire.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: halr@voltaire.com
In-Reply-To: <1123786117.4403.5835.camel@hal.voltaire.com>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

From: Hal Rosenstock <halr@voltaire.com>
Date: 11 Aug 2005 14:48:37 -0400

> The patch below is to accomodate IPoIB link layer address in the
> sockaddr_ll struct so that user space can send and receive IPoIB link
> later packets. Unfortunately, IPoIB has 20 bytes LL addresses rather
> than the 8 byte MAC addresses (or under) used by other LLs.

Two problems.  1) it's a really ugly IPoIB specific hack to extend the
sockaddr_ll structure, it won't work for anything else without adding
more special tests to that af_packet.c code and 2) you inproperly
rooted your patch, so we get stuff like this:

> --- af_packet.c.orig	2005-06-29 19:00:53.000000000 -0400
> +++ af_packet.c	2005-08-05 13:28:49.000000000 -0400

Please find another way to extend the structure.

That's why I didn't respond, this patch was too ugly for words
so it went to the bottom of my prioritized list of things to
do.
