From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [patch 7/9][NETNS][IPV6] make mld_max_msf per namespace
Date: Thu, 03 Jan 2008 12:00:48 +0100
Message-ID: <477CC060.10700@fr.ibm.com>
References: <OF222680D1.A9003264-ON882573C4.0080098D-882573C4.008140B5@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.29.150]:36566 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752659AbYACLI7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2008 06:08:59 -0500
In-Reply-To: <OF222680D1.A9003264-ON882573C4.0080098D-882573C4.008140B5@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Stevens wrote:
> Daniel,
>         I'm not sure what benefit you get from making this per-namespace.
> The point of it is really to prevent one (non-root, even) application from
> killing machine performance with source filters (because maintaining them
> is an n^2 algorithm). It's a weak constraint, but the resources it's 
> protecting are
> the processor and MLDv2 packet counts. If any one namespace has a
> large value, all will have a problem still, and  (even without your 
> patch),
> lots of separate source filters can still cause a problem. What it catches
> is one application creating thousands (or millions) of source filters and
> killing the machine and network with MLDv2 reports as a result. Why
> shouldn't that remain global?
> 
>                                                 +-DLS

Good point.

The problem you are pointing is in the case you have a namespace making 
this variable very big. And you are right this is a problem. But, if we 
make the variable global to all the namespaces, we will not able to 
reduce this value for a specific namespace.

I propose the following solution, at the namespace creation the variable 
value is copied from the initial network namespace, the modification of 
this variable is only valid if the value is less than the initial 
network namespace value.

With this solution, we can handle different values for the namespaces 
but these values are driven by the initial network namespace because 
their values are lesser or equal to the one from the initial network 
namespace.

Is it acceptable ?






























