From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: How to find I/F to destination
Date: Fri, 4 May 2007 17:20:09 +0400
Message-ID: <20070504132008.GB2291@2ka.mipt.ru>
References: <20070504125438.GA5439@2ka.mipt.ru> <5484.1178282928@redhat.com> <5910.1178284095@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:48424 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755166AbXEDNUv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2007 09:20:51 -0400
Content-Disposition: inline
In-Reply-To: <5910.1178284095@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 04, 2007 at 02:08:15PM +0100, David Howells (dhowells@redhat.com) wrote:
> 
> Should route_get_raw() release the rtable if gets back?

You can also cache returned entry and then just clone it and check
->obsolete() callback.

Something like this:
struct dst_entry *route_get(struct dst_entry *dst)
{
	if (dst && dst->obsolete && dst->ops->check(dst, 0) == NULL) {
		dst_release(dst);
		return NULL;
	}
	return dst_clone(dst);
}

Copied from route code too.

> David

-- 
	Evgeniy Polyakov
