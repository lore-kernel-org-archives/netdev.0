From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: Re: [PATCH v3 net-next 4/4] ulp: Documention for ULP
 infrastructure
Date: Thu, 3 Aug 2017 16:45:07 -0700 (PDT)
Message-ID: <alpine.OSX.2.21.1708031635290.29414@herbergs-mobl.ger.corp.intel.com>
References: <20170803193144.24108-1-tom@quantonium.net> <20170803193144.24108-5-tom@quantonium.net>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=US-ASCII
Cc: netdev@vger.kernel.org, rohit@quantonium.net, davejwatson@fb.com
To: Tom Herbert <tom@quantonium.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:20592 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751897AbdHCXpI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 3 Aug 2017 19:45:08 -0400
In-Reply-To: <20170803193144.24108-5-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 3 Aug 2017, Tom Herbert wrote:

> Add a doc in Documentation/networking
>
> Signed-off-by: Tom Herbert <tom@quantonium.net>
> ---
> Documentation/networking/ulp.txt | 82 ++++++++++++++++++++++++++++++++++++++++
> 1 file changed, 82 insertions(+)
> create mode 100644 Documentation/networking/ulp.txt
>
> diff --git a/Documentation/networking/ulp.txt b/Documentation/networking/ulp.txt
> new file mode 100644
> index 000000000000..4d830314b0ff
> --- /dev/null
> +++ b/Documentation/networking/ulp.txt
> @@ -0,0 +1,82 @@
> +Upper Layer Protocol (ULP) Infrastructure
> +=========================================
> +
> +The ULP kernel infrastructure provides a means to hook upper layer
> +protocol support on a socket. A module may register a ULP hook
> +in the kernel. ULP processing is enabled by a setsockopt on a socket
> +that specifies the name of the registered ULP to invoked. An
> +initialization function is defined for each ULP that can change the
> +function entry points of the socket (sendmsg, rcvmsg, etc.) or change
> +the socket in other fundamental ways.
> +
> +Note, no synchronization is enforced between the setsockopt to enable
> +a ULP and ongoing asynchronous operations on the socket (such as a
> +blocked read). If synchronization is required this must be handled by
> +the ULP and caller.
> +
> +User interface
> +==============
> +
> +The structure for the socket SOL_ULP options is defined in socket.h.
> +
> +Example to enable "my_ulp" ULP on a socket:
> +
> +struct ulp_config ulpc = {
> +    .ulp_name = "my_ulp",
> +};
> +
> +setsockopt(sock, SOL_SOCKET, SO_ULP, &ulpc, sizeof(ulpc))
> +
> +The ulp_config includes a "__u8 ulp_params[0]" filled that may be used
                                                   ^^^^^^
Did you mean "field"? Might also phrase it "The ulp_config structure 
includes..."

> +to refer ULP specific parameters being set.


Thanks,
