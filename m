From: Samuel Ortiz <sameo@linux.intel.com>
Subject: Re: [PATCH] nfc: Fix the sockaddr length sanitization in
 llcp_sock_connect
Date: Fri, 23 Jun 2017 00:27:17 +0200
Message-ID: <20170622222717.GE21214@zurbaran.ger.intel.com>
References: <20170524102620.13806-1-mjurczyk@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, security@kernel.org
To: Mateusz Jurczyk <mjurczyk@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170524102620.13806-1-mjurczyk@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Mateusz,

On Wed, May 24, 2017 at 12:26:20PM +0200, Mateusz Jurczyk wrote:
> Fix the sockaddr length verification in the connect() handler of NFC/LLCP
> sockets, to compare against the size of the actual structure expected on
> input (sockaddr_nfc_llcp) instead of its shorter version (sockaddr_nfc).
> 
> Both structures are defined in include/uapi/linux/nfc.h. The fields
> specific to the _llcp extended struct are as follows:
> 
>    276		__u8 dsap; /* Destination SAP, if known */
>    277		__u8 ssap; /* Source SAP to be bound to */
>    278		char service_name[NFC_LLCP_MAX_SERVICE_NAME]; /* Service name URI */;
>    279		size_t service_name_len;
> 
> If the caller doesn't provide a sufficiently long sockaddr buffer, these
> fields remain uninitialized (and they currently originate from the stack
> frame of the top-level sys_connect handler). They are then copied by
> llcp_sock_connect() into internal storage (nfc_llcp_sock structure), and
> could be subsequently read back through the user-mode getsockname()
> function (handled by llcp_sock_getname()). This would result in the
> disclosure of up to ~70 uninitialized bytes from the kernel stack to
> user-mode clients capable of creating AFC_NFC sockets.
> 
> Signed-off-by: Mateusz Jurczyk <mjurczyk@google.com>
> ---
>  net/nfc/llcp_sock.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
Applied to nfc-next, thanks.

Cheers,
Samuel.
