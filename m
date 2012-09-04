From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [iproute2][PATCH v2] tc: mirred target: do not report
 non-existing devices
Date: Tue, 4 Sep 2012 08:40:29 -0700
Message-ID: <20120904084029.04ffeae0@nehalam.linuxnetplumber.net>
References: <20120902104107.GB8982@redhat.com>
	<1346582882-14568-1-git-send-email-y>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	Dan Kenigsberg <danken@redhat.com>
To: y@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55259 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753204Ab2IDPk5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Sep 2012 11:40:57 -0400
In-Reply-To: <1346582882-14568-1-git-send-email-y>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun,  2 Sep 2012 13:48:02 +0300
y@redhat.com wrote:

> From: Dan Kenigsberg <danken@redhat.com>
> 
> Currently, if a mirred target device is removed, `tc filter show`
> does not reveal the fact. Instead, it replaces the original name of the
> device with the default output of ll_map:ll_idx_n2a().
> 
> This is unfortunate, since one cannot differ between this case and a valid
> mirroring target device named 'if17'.
> 
> It seems that the original code meant to report an error message in this
> case, but it does not, since ll_index_to_name() never returns 0. I would
> not like to bail out in case of an error, since the user would still be
> interested to know what are the other details of the action.
> 
> v2: properly declare the new function ll_index_exsits()

I am okay with the concept but  "missing-if1" is still a possible
but unlikely name for a device.  Maybe better to use something more
obvious like [unknown-1] or UNKNOWN? 
