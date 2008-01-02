From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [patch 7/9][NETNS][IPV6] make mld_max_msf per namespace
Date: Wed, 2 Jan 2008 15:31:48 -0800
Message-ID: <OF222680D1.A9003264-ON882573C4.0080098D-882573C4.008140B5@us.ibm.com>
References: <20080102122827.779444823@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:37513 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754855AbYABXbz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jan 2008 18:31:55 -0500
In-Reply-To: <20080102122827.779444823@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel,
        I'm not sure what benefit you get from making this per-namespace.
The point of it is really to prevent one (non-root, even) application from
killing machine performance with source filters (because maintaining them
is an n^2 algorithm). It's a weak constraint, but the resources it's 
protecting are
the processor and MLDv2 packet counts. If any one namespace has a
large value, all will have a problem still, and  (even without your 
patch),
lots of separate source filters can still cause a problem. What it catches
is one application creating thousands (or millions) of source filters and
killing the machine and network with MLDv2 reports as a result. Why
shouldn't that remain global?

                                                +-DLS

