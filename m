From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: inconsistency of ethtool feature names for get vs. set
Date: Thu, 2 Jan 2014 11:47:37 +0200
Message-ID: <52C535B9.7080208@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog120.obsmtp.com ([207.126.144.149]:48879 "EHLO
	eu1sys200aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750707AbaABJvi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 04:51:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben,

I noticed some inconsistency of feature names with the ethtool 
getting/setting of features mechanics -- the name of the feature you 
need to set (through -K) isn't what displayed by the get (-k) directive, 
here's an example:

$ ethtool -k eth1  | grep generic-receive-offload
generic-receive-offload: on

$ ethtool -K eth1  generic-receive-offload off
ethtool: bad command line argument(s)
For more information run ethtool -h

--> looking in the sources and realizing I need to use "rx-gro"

$ ethtool -K eth1  rx-gro on

$ethtool -k eth1  | grep generic-receive-offload
generic-receive-offload: on

same problem for rx checksum which is displayed as "rx-checksumming" by 
the get (-k)
but need to be "rx-checksum" for the set (-K) directive.

Basically, this can be resolved by fairly simple patch, but I wasn't 
sure if you want it in user space, in the kernel or both...

Or.
