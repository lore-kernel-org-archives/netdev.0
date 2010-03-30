From: James Chapman <jchapman@katalix.com>
Subject: Re: Re [RFC PATCH 1/2] iproute2: Add libnl support.
Date: Tue, 30 Mar 2010 08:48:42 +0100
Message-ID: <4BB1ACDA.8030808@katalix.com>
References: <20100329140642.7305bdfc@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:45685 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752764Ab0C3Hsv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Mar 2010 03:48:51 -0400
In-Reply-To: <20100329140642.7305bdfc@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
>> This patch links the ip utility with libnl, which must be separately
>> installed. This lets new functionality use libnl to implement its
>> netlink interfaces.
>>
>> Package developers will need to add libnl to the iproute2 package
>> dependencies.
>> ---
>>  Makefile |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> No. I don't want to make iproute2 dependent on libnl.
> It doesn't make sense to have dependency without major need for new
> functionality.  There are already netlink library routines in iproute2

True, but libnetlink doesn't provide utility routines for building genl
interfaces like it does, say, for rtnl. To use libnetlink for this code,
we'd have to c&p some code from genl/ctrl.c to handle the interface
family registration, for example. It's all there in libnl already.

But I understand your reservation about introducing a new library
dependency. Since the rest of our netlink code uses libnl, I'm leaning
towards having a separate utility for these commands so we can keep it
libnl.

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

