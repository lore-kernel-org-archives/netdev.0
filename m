From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v4 3/5] vxlan: add ipv6 support
Date: Fri, 19 Apr 2013 19:35:34 +0800
Message-ID: <1366371334.5117.5.camel@cr0>
References: <1366175423-27310-1-git-send-email-amwang@redhat.com>
	 <1366175423-27310-4-git-send-email-amwang@redhat.com>
	 <20130418143407.GA28374@zed.ravello.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Stevens <dlstevens@us.ibm.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>
To: Mike Rapoport <mike.rapoport@ravellosystems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45565 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S968197Ab3DSLgg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Apr 2013 07:36:36 -0400
In-Reply-To: <20130418143407.GA28374@zed.ravello.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-04-18 at 17:34 +0300, Mike Rapoport wrote:
> When building vxlan as module I get:
>=20
> MODPOST 45 modules
> VOFFSET arch/x86/boot/voffset.h
> CC      arch/x86/boot/version.o
> AS      arch/x86/boot/compressed/head_64.o
> ERROR: "in6addr_loopback" [drivers/net/vxlan.ko] undefined!
>=20
> Seems, that either in6addr_loopback should be exported, or
> IN6ADDR_LOOPBACK_INIT should be used as initializer for
> loopback.va_sin6.

I tried IN6ADDR_LOOPBACK_INIT before in6addr_loopback and got:

drivers/net/vxlan.c:1086:31: error: expected expression before =E2=80=98=
{=E2=80=99 token

So I think we have to export in6addr_loopback.

Thanks for catching it!
