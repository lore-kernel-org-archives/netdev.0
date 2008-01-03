From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [patch 7/9][NETNS][IPV6] make mld_max_msf per namespace
Date: Thu, 3 Jan 2008 09:05:03 -0800
Message-ID: <OF791A0627.98C1ADFA-ON882573C5.005B56DB-882573C5.005DD825@us.ibm.com>
References: <477CC060.10700@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:51360 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756661AbYACRFH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2008 12:05:07 -0500
In-Reply-To: <477CC060.10700@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Lezcano <dlezcano@fr.ibm.com> wrote on 01/03/2008 03:00:48 AM:
...
> With this solution, we can handle different values for the namespaces 
> but these values are driven by the initial network namespace because 
> their values are lesser or equal to the one from the initial network 
> namespace.
> 
> Is it acceptable ?

Daniel,
        If you have the premise that there's a reason for them to be
different, then your original implementation is fine already. It
requires root privilege to change the value, so I don't mind the
ability to raise it to a higher value later.
        I don't object, but I don't understand. I can't think of
any circumstances where I would want to modify it per namespace.
Making it small is not an effective restriction, since someone
*wanting* to use lots of sources can simply do them on different
sockets of the same group. The point is to catch accidental silly
use and it's protecting a global resource so differing values
just change the threshold at which you catch accidental silly
use in different namespaces.
        Setting it to "0" might be a method of preventing its
use entirely in some namespaces, but it's part of the socket
interface-- disabling it isn't something you generally want to
do, either.
        Are you intending to convert all variables to be
per-namespace? If not -- that is, if you will have global
sysctl variables, then I think this one should be one of
those. Actually, all of the IGMP & MLD variables are tied
naturally to the shared interfaces, so should be global,
I think.

                                                        +-DLS

