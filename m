From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: TCP 2MSL on loopback
Date: Mon, 5 Mar 2007 15:28:02 +0100
Message-ID: <200703051528.02564.dada1@cosmosbay.com>
References: <45EBFD13.1060106@symas.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Howard Chu <hyc@symas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:53513 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933471AbXCEO2I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Mar 2007 09:28:08 -0500
In-Reply-To: <45EBFD13.1060106@symas.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 05 March 2007 12:20, Howard Chu wrote:
> Why is the Maximum Segment Lifetime a global parameter? Surely the
> maximum possible lifetime of a particular TCP segment depends on the
> actual connection. At the very least, it would be useful to be able to
> set it on a per-interface basis. E.g., in the case of the loopback
> interface, it would be useful to be able to set it to a very small
> duration.

Hi Howard

I think you should address these questions on netdev instead of linux-kernel.

>
> As I note in this draft
> http://www.ietf.org/internet-drafts/draft-chu-ldap-ldapi-00.txt
> when doing a connection soak test of OpenLDAP using clients connected
> through localhost, the entire port range is exhausted in well under a
> second, at which point the test stalls until a port comes out of
> TIME_WAIT state so the next connection can be opened.
>
> These days it's not uncommon for an OpenLDAP slapd server to handle tens
> of thousands of connections per second in real use (e.g., at Google, or
> at various telcos). While the LDAP server is fast enough to saturate
> even 10gbit ethernet using contemporary CPUs, we have to resort to
> multiple virtual interfaces just to make sure we have enough port
> numbers available.
>

I dont uderstand... doesnt slapd server listen for connections on a given 
port, like http ? Or is it doing connections like a ftp server ?

Of course, if you want to open more than 60.000 concurrent connections, using 
127.0.0.1 address, you might have a problem...

> Ideally the 2MSL parameter would be dynamically adjusted based on the
> route to the destination and the weights associated with those routes.
> In the simplest case, connections between machines on the same subnet
> (i.e., no router hops involved) should have a much smaller default value
> than connections that traverse any routers. I'd settle for a two-level
> setting - with no router hops, use the small value; with any router hops
> use the large value.

Well, is it really a MSL problem ?

I did a small test (linux-2.6.21-rc1) and was able to get 1.000.000 
connections on localhost on my dual proc machine in one minute, without an 
error.

