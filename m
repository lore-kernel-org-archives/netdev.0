From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Bugs in xfrm
Date: Fri, 9 Jan 2004 20:48:08 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040109204808.3db77be6.davem@redhat.com>
References: <20031108223049.36651f8d.davem@redhat.com>
	<Pine.LNX.4.44.0401091339170.10121-100000@linux-udp14999547uds>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, krkumar@us.ibm.com, kumarkr@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Krishna Kumar <krkumar@us.ibm.com>
In-Reply-To: <Pine.LNX.4.44.0401091339170.10121-100000@linux-udp14999547uds>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 9 Jan 2004 17:40:03 -0800 (PST)
Krishna Kumar <krkumar@us.ibm.com> wrote:

> These changes compile cleanly, but I couldn't test since these are
> corner cases. Please let me know if this can be applied. I am sending
> as one patch file for now instead of multiple files as they all small.

Maybe you should actually try to test these changes before I think
about applying them, for example:

> +void dst_bundle_free(struct dst_entry *dst)
> +{
> +	struct dst_entry *next;
> +
> +	while (dst) {
> +		next = dst->child;
> +		dst_free(dst);
> +	}
> +}

Explain to me how that won't loop forever if given a non-NULL dst?

Next, this dst_bundle_free() thing is totally not needed as far as I can
tell.  When dst_free() is made, the top-level of the bundle's dst gets added
to the garbage collection list, the garbage collection properly walks the
children to process the whole bundle.

Please redo this patch and please test it this time :)
