From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [RFC] Stable interface index option
Date: Tue, 1 Dec 2015 10:34:41 -0500
Message-ID: <20151201153441.GA17843@oracle.com>
References: <20151201120420.GT12404@principal.rfc2324.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:33254 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750984AbbLAPeq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 10:34:46 -0500
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by aserp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id tB1FYjBt008260
	(version=TLSv1 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 1 Dec 2015 15:34:45 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserv0022.oracle.com (8.13.8/8.13.8) with ESMTP id tB1FYjYP019373
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Tue, 1 Dec 2015 15:34:45 GMT
Received: from abhmp0014.oracle.com (abhmp0014.oracle.com [141.146.116.20])
	by aserv0121.oracle.com (8.13.8/8.13.8) with ESMTP id tB1FYjHd026418
	for <netdev@vger.kernel.org>; Tue, 1 Dec 2015 15:34:45 GMT
Content-Disposition: inline
In-Reply-To: <20151201120420.GT12404@principal.rfc2324.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (12/01/15 13:04), Maximilian Wilhelm wrote:
> 
> The reason we would like to have those is quite simple: As we operate
> a somewhat larger network we would like to monitor it accordingly and
> see when links get saturated etc. Therefore we used snmp based
> solutions and the net-snmp daemon on all the boxes. Now SNMP uses
> interface indexes for identifying the interfaces. If they aren't
> stable the monitoring software will see a lot of new interfaces now
> and then, e.g. after a OpenVPN server/client restarted (which is bad)
> or even mix up interfaces (which is worse).

FWIW, this is how router implementations such as cisco network OS-es
deal with this issue- every interface has 2 32-bit integers associated
with it, one is the "snmp-ifindex", conformant with rfc 2863, 
that never changes, and encodes positional information like slot#,
chassis#, card type etc.  This number is sparse (i.e., it
is not necessarily a consecutive number space) Encoding is implementation
specific, of course, and macros are supplied if you want to look into
the encoding itself.

the other number is the one used internally by the network stack,
and is subject to frequent change, as interfaces come and go (up/down,
virtual interfaces change etc). This is a packed number-space- next
available index is handed to each interface as it comes up.

SNMP mibs publish the first number, and apps can use that number
to uniquely identify an interface. 

If there are enough apps that rely on an immutable index to identify
an interface, it might be worthwhile to consider this type of approach.

> +	if (!dev->ifindex) {
> +		if (strcmp (dev->name, "gre_ffrl_fra_a") == 0) {
> +			ifindex = 23;
> +		} else if (strcmp (dev->name, "bb-pad-cr01") == 0) {
> +			ifindex = 42;
> +		}

I'm not sure I understand how this would work- are we going to 
pin down the ifindex for some subset of interfaces?
