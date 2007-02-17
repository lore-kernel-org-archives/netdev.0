From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [RFC] [PATCH] Network Events Connector
Date: Sat, 17 Feb 2007 19:34:22 +0300
Message-ID: <20070217163422.GB22369@2ka.mipt.ru>
References: <m2irecym8t.fsf@cerbere.dyndns.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
To: Samir Bellabes <sam@synack.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:37994 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992448AbXBQQei (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Feb 2007 11:34:38 -0500
Content-Disposition: inline
In-Reply-To: <m2irecym8t.fsf@cerbere.dyndns.info>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 09, 2007 at 05:43:14AM +0100, Samir Bellabes (sam@synack.fr) wrote:
> Hi,
> 
> Here is a new feature which can help firewalls to be more application
> aware, so more useful for people.
> 
> Our previous discussion about cn_net and firewalls:
> http://marc2.theaimsgroup.com/?t=115976957500002&r=1&w=2
> 
> Please, I would really like to have feedback and comments on that tool,
> in order to improve it.

Technical side does have problems.
1. your way to delete and check events is wrong - there is no need to
allocate new event and search for it in the hash table to remove - use
values as is.
2. initialization path has problems - hash is allocated after securty
hooks and connector moduler are registered.
3. why hash table and not rb tree?
4. are you 100% sure there are misalignments and 32/64 bit userspace
problems? you seems to copy some bits from proc connector, which
suffered from that errors in the past.

> Thanks a lot,
> Samir Bellabes

-- 
	Evgeniy Polyakov
