From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [7/7] dst: kconfig and makefile changes.
Date: Tue, 30 Dec 2008 09:26:28 -0800
Message-ID: <20081230092628.16662796.randy.dunlap@oracle.com>
References: <1230292576-23963-1-git-send-email-zbr@ioremap.net>
	<1230292576-23963-2-git-send-email-zbr@ioremap.net>
	<1230292576-23963-3-git-send-email-zbr@ioremap.net>
	<1230292576-23963-4-git-send-email-zbr@ioremap.net>
	<1230292576-23963-5-git-send-email-zbr@ioremap.net>
	<1230292576-23963-6-git-send-email-zbr@ioremap.net>
	<1230292576-23963-7-git-send-email-zbr@ioremap.net>
	<1230292576-23963-8-git-send-email-zbr@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, dst@ioremap.net,
	netdev@vger.kernel.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:48619 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751932AbYL3R1O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Dec 2008 12:27:14 -0500
In-Reply-To: <1230292576-23963-8-git-send-email-zbr@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 26 Dec 2008 14:56:16 +0300 Evgeniy Polyakov wrote:

> Signed-off-by: Evgeniy Polaykov <zbr@ioremap.net>
> 
> diff --git a/drivers/block/dst/Kconfig b/drivers/block/dst/Kconfig
> new file mode 100644
> index 0000000..12ffa37
> --- /dev/null
> +++ b/drivers/block/dst/Kconfig
> @@ -0,0 +1,71 @@
> +config DST
> +	tristate "Distributed storage"
> +	depends on NET && CRYPTO && SYSFS
> +	select CONNECTOR
> +	select LIBCRC32C
> +	---help---
> +	DST is a network block device storage, which can be used to organize
> +	exported storages on the remote nodes into the local block device.
> +
> +	DST is a network block device storage, which can be used to organize
> +	exported storages on the remote nodes into the local block device.
> +
(I thought that I had already reported this...)

Above paragraph is duplicated.  Also, "storages" isn't proper AFAIK.
Just use "storage".


> +	DST works on top of any network media and protocol, it is just a matter

s/,/;/

> +	of configuration utility to understand the correct addresses. The most
> +	common example is TCP over IP allows to pass through firewalls and

	                      over IP, which can pass through firewalls and

> +	created remote backup storage in the different datacenter. DST requires

	create remote backup storage in a different

> +	single port to be enabled on the exporting node and outgoing connections
> +	on the local node.
> +
> +	DST works with in-kernel client and server, which improves the performance

	                                                  improves performance by

> +	eliminating unneded data copies and allows not to depend on the version

	                                and by not depending on the version

> +	of the external IO components. It requires userspace configuration utility
> +	though.
> +
> +	DST uses transaction model, when each store has to be explicitly acked
> +	from the remote node to be considered as successfully written. There
> +	may be lots of in-flight transactions. When remote host does not ack
> +	the transaction it will be resent predefined number of times with specified
> +	timeouts between them. All those parameters are configurable. Transactions
> +	are marked as failed after all resends completed unsuccessfully, having

	                                       complete unsuccessfully; having

> +	long enough resend timeout and/or large number of resends allows not to
> +	return error to the higher (FS usually) layer in case of short network
> +	problems or remote node outages. In case of network RAID setup this means
> +	that storage will not degrade until transactions are marked as failed, and
> +	thus will not force checksum recalculation and data rebuild. In case of
> +	connection failure DST will try to reconnect to the remote node automatically.
> +	DST sends ping commands at idle time to detect if remote node is alive.
> +
> +	Because of transactional model it is possible to use zero-copy sending
> +	without worry of data corruption (which in turn could be detected by the
> +	strong checksums though).
> +
> +	DST may fully encrypt the data channel in case of untrusted channel and implement
> +	strong checksum of the transferred data. It is possible to configure algorithms
> +	and crypto keys, they should match on both sides of the network channel.

	           keys;

> +	Crypto processing does not introduce noticeble performance overhead, since DST
> +	uses configurable pool of threads to perform crypto processing.
> +
> +	DST utilizes memory pool model of all its transaction allocations (it is the
> +	only additional allocation on the client) and server allocations (bio pools,
> +	while pages are allocated from the slab).
> +
> +	At startup DST performs a simple negotiation with the export node to determine
> +	access permissions and size of the exported storage. It can be extended if
> +	new parameters should be autonegotiated.
> +
> +	DST carries block IO flags in the protocol, which allows to transparently implement
> +	barriers and sync/flush operations. Those flags are used in the export node where
> +	IO against the local storage is performed, which means that sync write will be sync
> +	on the remote node too, which in turn improves data integrity and improved resistance
> +	to errors and data corruption during power outages or storage damages.
> +
> +	Homepage: http://www.ioremap.net/projects/dst
> +	Userspace configuration utility and the latest releases: http://www.ioremap.net/archive/dst/
> +
> +config DST_DEBUG
> +	bool "DST debug"
> +	depends on DST
> +	---help---
> +	This option will turn HEAVY debugging of the DST.

	                 s/turn/enable/

> +	Turn it on ONLY if you have to debug some really obscure problem.


---
~Randy
