From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH] sctp: Add documentation for sctp sysctl variable
Date: Tue, 8 Jul 2008 13:31:58 -0700
Message-ID: <20080708133158.0c39d355.randy.dunlap@oracle.com>
References: <1215546766-10014-1-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:27142 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752015AbYGHUgT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 16:36:19 -0400
In-Reply-To: <1215546766-10014-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  8 Jul 2008 15:52:46 -0400 Vlad Yasevich wrote:

> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
> ---
>  Documentation/networking/ip-sysctl.txt |  167 ++++++++++++++++++++++++++++++++
>  1 files changed, 167 insertions(+), 0 deletions(-)
> 
> diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
> index 17a6e46..e92b3d5 100644
> --- a/Documentation/networking/ip-sysctl.txt
> +++ b/Documentation/networking/ip-sysctl.txt
> @@ -1064,6 +1064,173 @@ bridge-nf-filter-pppoe-tagged - BOOLEAN
>  	Default: 1
>  
>  
> +proc/sys/net/sctp/* Variables:
> +addip_enable - BOOLEAN
> +	Enable or disable extension of  Dynamic Address Reconfiguration
> +	(ADD-IP) functionality specified in RFC5061.  This extension provides
> +	the ability to dynamically add and remove new addresses for the SCTP
> +        associations.
> +

Please fix tab/space alignment above and below.

> +	1: Enable extension.
> +
> +        0: Disable extenson.

                      extension.

> +
> +	Default: 0
> +
> +addip_noauth_enable - BOOLEAN
> +	The Dynamic Address Reconfiguration (ADD-IP) requires the use of

	Drop "The".

> +	authentication to protect the operations of add or removing new

s/add/adding/

> +	addresses.  This requirement is mandated so that unauthorized hosts
> +	would not be able to hijack associations.  However, older
> +	implementations may not have implemented this requirement while
> +	allowing the ADD-IP extension.  For reasons of interoperability,
> +	we provide this variable to control the enforcement of the
> +	authentication requirement.
> +
> +	1: Allow ADD-IP extension to be used without authentication.  This
> +	   should only be set in a closed environment for for interoperability

s/for for/for/

> +	   with older implementations.
> +
> +	0: Enforce the authenticaion requirement

	               authentication

> +
> +	Default: 0
> +	
> +auth_enable - BOOLEAN
> +	Enable of disable Autheticated Chunks extensions.  This extensions

	       or         Authenticated       extension.        extension

> +	provides the ability to send and recieve authenticated chunks and is

	                                 receive

> +	required for secure operation of Dynamic Address Reconfiguration
> +	(ADD-IP) extension.
> +
> +	1: Enable this extension.
> +	0: Disable this extension.
> +
> +	Default: 0
> +
> +prsctp_enable - BOOLEAN
> +	Enable or disable the Partial Reliability extension (RFC3758) which
> +	is used to notify peers that a given DATA should no longer be expected.
> +
> +	1: Enable extension
> +	0: Disable
> +
> +	Default: 1
> +
> +max_burst - INTEGER
> +	The limit of the number of new packets that can be initially sent.  Its

	                                                                    It

> +	controls how busty the generated traffic can be.

        controls     bursty

> +
> +	Default: 4
> +
> +association_max_retrans - INTEGER
> +	Set the maximum number for retransmissions that an association can
> +	attempt deciding that the remote end is unreachable.  If this value
> +	is exceeded, the association is terminated.
> +
> +	Default: 10
> +
> +max_init_retransmits - INTEGER
> +	The maximum number of retransmissions of INIT and COOKIE-ECHO chunks
> +	that an association will attempt before declaring the destination
> +	unreachable and terminating.
> +
> +	Default: 8
> +
> +path_max_retrans - INTEGER
> +	The maximum number of retransmissions that will attempted on a given

	                                      that will be attempted

> +	path.  Once this threshold is exceeded, the path is considered
> +	unreachable, and new traffic will use a different path when the
> +	association is multihomed.
> +
> +	Default: 5
> +
> +rto_initial - INTEGER
> +	The initial round trip timeout value in millisecods that will be used
> +	in calculating rount trip times.  This is the initial time interval
> +	for retransmissions.
> +
> +	Default: 3000
> +
> +rto_max - INTEGER
> +	The maximum value (in milliseconds) of the round trip timeout.  This
> +	is the largest time interval that can elapse between retransmissions.
> +
> +	Default: 60000
> +
> +rto_min - INTEGER
> +	The minimum value (in milliseconds) of the round trip timeout.  This
> +	is the smallest time interval the can elapse between retransmissions.
> +
> +	Default: 1000
> +
> +hb_interval - INTEGER
> +	The interval (in milliseconds) between HEARTBEAT chunks.  These chunks
> +	are sent at the specified interval on idle paths to probe the state of
> +	a given path between 2 associations.
> +
> +	Defautl: 30000 ms

	Default:       (drop ms; none of the others have it)

> +    
> +sack_timeout - INTEGER
> +	The amount of time (in milliseconds) that the implementation will wait
> +	to send a SACK.
> +
> +	Default: 200
> +
> +valid_cookie_life - INTEGER
> +	The default lifetime of the SCTP cookie (in millisecons).  The cookie

	                                            milliseconds).

> +	is used during association establishement.

	                           establishment.

> +
> +cookie_preserve_enable - BOOLEAN
> +	Enable or disable the ability to extend the lifetime of the SCTP cookie
> +	that is used during the establishment phase of SCTP association
> +
> +	1: Enable cookie lifetime extension.
> +	0: Disable
> +
> +	Default: 1
> +
> +rcvbuf_policy - INTEGER
> +	Determines if the receive buffer is attributed to the socket or to
> +	association.   SCTP supports the capability to create multiple
> +	asocaitions on a single socket.  When using this capability, it is

	associations

> +	possible that a single stalled association that's buffering a lot
> +	of data may block other associations from delivering their data by
> +	consuming all of the receive buffer space.  To work around this,
> +	the rcvbuf_policy could be set to attribute the receiver buffer space
> +	to each association instead of the socket.  This prevents the described
> +	blocking.
> +
> +	1: rcvbuf space is per association
> +	0: recbuf space is per socket
> +	
> +	Default: 0
> +	
> +sndbuf_policy - INTEGER
> +	Similar to rcvbuf_policy above, the applies to send buffer space.

	                                ^^^ s/the/this/

> +
> +	1: Send buffer is tracked per association
> +	0: Send buffer is tracked per socket.
> +
> +	Default: 0
> +
> +sctp_mem - vector of 3 INTEGERs: min, pressure, max
> +	Number of pages allowed for queueing by all SCTP sockets.
> +
> +	min: Below this number of pages SCTP is not bothered about its
> +	memory appetite. When amount of memory allocated by SCTP exceeds
> +	this number, SCTP starts to moderate memory usage.
> +
> +	pressure: This value was introduced to follow format of tcp_mem.
> +
> +	max: Number of pages allowed for queueing by all SCTP sockets.
> +
> +	Default is calculated at boot time from amount of available memory.
> +	
> +sctp_rmem - vector of 3 INTEGERs: min, default, max
> +	See tcp_rmem for a description.
> +
> +sctp_wmem  - vector of 3 INTEGERs: min, default, max
> +	See tcp_wmem for a description.
> +
>  UNDOCUMENTED:
>  
>  dev_weight FIXME
> -- 

---
~Randy
Linux Plumbers Conference, 17-19 September 2008, Portland, Oregon USA
http://linuxplumbersconf.org/
