From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [iproute PATCH 1/2] tc: m_action: Fix for field init before
 memset
Date: Tue, 14 Jun 2016 16:51:36 -0700
Message-ID: <20160614165136.51b6d4ff@xeon-e3>
References: <1465943169-4101-1-git-send-email-phil@nwl.cc>
	<1465943169-4101-2-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Phil Sutter <psutter@redhat.com>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:40238 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751339AbcFNXv3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 19:51:29 -0400
In-Reply-To: <1465943169-4101-2-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 15 Jun 2016 00:26:08 +0200
Phil Sutter <phil@nwl.cc> wrote:

> From: Phil Sutter <psutter@redhat.com>
> 
> Initializing req.t.tca_family before setting the whole req object to
> zero using memset does not make sense. Instead initialize the field
> after calling memset.
> 
> Note that this change has no functional effect since AF_UNSPEC is
> defined to 0 anyway, so this fix is a purely cosmetic one.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Instead of moving around the code with memset(), it would make more
sense to change this and other places to use C99 style initializers.
They are safer and the code is cleaner.
