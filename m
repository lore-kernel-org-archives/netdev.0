From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH/RFC] synchronize_rcu(): high latency on idle system
Date: Sun, 13 Jan 2008 16:34:17 +0100
Message-ID: <200801131634.17677.ak@suse.de>
References: <20080112012626.GI28570@kvack.org> <200801121935.58286.ak@suse.de> <20080112175226.7d8f9dbc@deepthought>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kerne@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:57375 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751226AbYAMPeV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Jan 2008 10:34:21 -0500
In-Reply-To: <20080112175226.7d8f9dbc@deepthought>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> I think it should be in netdev_unregister_kobject().  But that would
> only get rid of one of the two calls to synchronize_rcu() in the unregister_netdev.

Would be already an improvement.

> The other synchronize_rcu() is for qdisc's and not sure if that one can
> be removed?

The standard way to remove such calls is to set a "deleted" flag in the object,
then check and ignore such objects in the reader and finally remove the object with
call_rcu

I have not checked if that is really feasible for qdiscs.

-Andi
